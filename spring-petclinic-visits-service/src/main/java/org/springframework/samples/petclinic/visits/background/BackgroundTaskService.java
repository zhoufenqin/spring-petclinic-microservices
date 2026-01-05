/*
 * Copyright 2002-2021 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.springframework.samples.petclinic.visits.background;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Service for managing and executing background tasks.
 * Supports concurrent task execution and task delegation.
 *
 * @author Spring Petclinic Team
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class BackgroundTaskService {

    private final BackgroundTaskRepository taskRepository;
    private final Map<String, TaskExecutor> taskExecutors = new ConcurrentHashMap<>();

    /**
     * Register a task executor for a specific task type.
     *
     * @param executor the task executor to register
     */
    public void registerExecutor(TaskExecutor executor) {
        taskExecutors.put(executor.getTaskType(), executor);
        log.info("Registered task executor for type: {}", executor.getTaskType());
    }

    /**
     * Submit a new background task for execution.
     *
     * @param taskType the type of task
     * @param taskData the task data
     * @return the created task
     */
    @Transactional
    public BackgroundTask submitTask(String taskType, String taskData) {
        BackgroundTask task = BackgroundTask.builder()
            .taskType(taskType)
            .taskData(taskData)
            .status(BackgroundTask.TaskStatus.PENDING)
            .retryCount(0)
            .build();

        task = taskRepository.save(task);
        log.info("Submitted background task: id={}, type={}", task.getId(), task.getTaskType());

        return task;
    }

    /**
     * Execute a task asynchronously.
     * This method delegates task execution to the background worker pool.
     *
     * @param taskId the ID of the task to execute
     */
    @Async
    @Transactional
    public void executeTaskAsync(Long taskId) {
        BackgroundTask task = taskRepository.findById(taskId).orElse(null);
        if (task == null) {
            log.error("Task not found: {}", taskId);
            return;
        }

        if (task.getStatus() != BackgroundTask.TaskStatus.PENDING) {
            log.warn("Task {} is not in PENDING status, current status: {}", taskId, task.getStatus());
            return;
        }

        task.setStatus(BackgroundTask.TaskStatus.RUNNING);
        task.setStartedAt(LocalDateTime.now());
        taskRepository.save(task);

        try {
            TaskExecutor executor = taskExecutors.get(task.getTaskType());
            if (executor == null) {
                throw new IllegalStateException("No executor registered for task type: " + task.getTaskType());
            }

            log.info("Executing task: id={}, type={}", task.getId(), task.getTaskType());
            executor.execute(task);

            task.setStatus(BackgroundTask.TaskStatus.COMPLETED);
            task.setCompletedAt(LocalDateTime.now());
            log.info("Task completed successfully: id={}", task.getId());

        } catch (Exception e) {
            log.error("Task execution failed: id={}, error={}", task.getId(), e.getMessage(), e);
            task.setStatus(BackgroundTask.TaskStatus.FAILED);
            task.setErrorMessage(e.getMessage());
            task.setRetryCount(task.getRetryCount() + 1);
        } finally {
            taskRepository.save(task);
        }
    }

    /**
     * Process pending tasks periodically.
     * This scheduled task checks for pending tasks and delegates them to background workers.
     */
    @Scheduled(fixedDelay = 5000)
    @Transactional
    public void processPendingTasks() {
        List<BackgroundTask> pendingTasks = taskRepository.findByStatus(BackgroundTask.TaskStatus.PENDING);

        if (!pendingTasks.isEmpty()) {
            log.info("Found {} pending tasks to process", pendingTasks.size());

            // Execute tasks concurrently by delegating to async workers
            for (BackgroundTask task : pendingTasks) {
                executeTaskAsync(task.getId());
            }
        }
    }

    /**
     * Get a task by ID.
     *
     * @param taskId the task ID
     * @return the task
     */
    public BackgroundTask getTask(Long taskId) {
        return taskRepository.findById(taskId).orElse(null);
    }

    /**
     * Get all tasks.
     *
     * @return list of all tasks
     */
    public List<BackgroundTask> getAllTasks() {
        return taskRepository.findAll();
    }

    /**
     * Get tasks by status.
     *
     * @param status the task status
     * @return list of tasks with the given status
     */
    public List<BackgroundTask> getTasksByStatus(BackgroundTask.TaskStatus status) {
        return taskRepository.findByStatus(status);
    }

    /**
     * Cancel a task.
     *
     * @param taskId the task ID
     * @return true if cancelled, false otherwise
     */
    @Transactional
    public boolean cancelTask(Long taskId) {
        BackgroundTask task = taskRepository.findById(taskId).orElse(null);
        if (task == null) {
            return false;
        }

        if (task.getStatus() == BackgroundTask.TaskStatus.PENDING) {
            task.setStatus(BackgroundTask.TaskStatus.CANCELLED);
            taskRepository.save(task);
            log.info("Task cancelled: id={}", taskId);
            return true;
        }

        return false;
    }
}
