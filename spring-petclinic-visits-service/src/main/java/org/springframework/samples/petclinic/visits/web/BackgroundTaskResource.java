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
package org.springframework.samples.petclinic.visits.web;

import io.micrometer.core.annotation.Timed;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.samples.petclinic.visits.background.BackgroundTask;
import org.springframework.samples.petclinic.visits.background.BackgroundTaskService;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import java.util.List;

/**
 * REST controller for managing background tasks.
 * Provides endpoints for task submission, status checking, and cancellation.
 *
 * @author Spring Petclinic Team
 */
@RestController
@RequestMapping("/background-tasks")
@RequiredArgsConstructor
@Slf4j
@Timed("petclinic.background-task")
public class BackgroundTaskResource {

    private final BackgroundTaskService backgroundTaskService;

    /**
     * Submit a new background task.
     *
     * @param request the task submission request
     * @return the created task
     */
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public BackgroundTask submitTask(@Valid @RequestBody TaskSubmissionRequest request) {
        log.info("Submitting background task: type={}", request.getTaskType());
        return backgroundTaskService.submitTask(request.getTaskType(), request.getTaskData());
    }

    /**
     * Get a task by ID.
     *
     * @param taskId the task ID
     * @return the task
     */
    @GetMapping("/{taskId}")
    public BackgroundTask getTask(@PathVariable Long taskId) {
        BackgroundTask task = backgroundTaskService.getTask(taskId);
        if (task == null) {
            throw new TaskNotFoundException("Task not found: " + taskId);
        }
        return task;
    }

    /**
     * Get all tasks.
     *
     * @return list of all tasks
     */
    @GetMapping
    public List<BackgroundTask> getAllTasks() {
        return backgroundTaskService.getAllTasks();
    }

    /**
     * Get tasks by status.
     *
     * @param status the task status
     * @return list of tasks with the given status
     */
    @GetMapping("/status/{status}")
    public List<BackgroundTask> getTasksByStatus(@PathVariable BackgroundTask.TaskStatus status) {
        return backgroundTaskService.getTasksByStatus(status);
    }

    /**
     * Cancel a task.
     *
     * @param taskId the task ID
     */
    @DeleteMapping("/{taskId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void cancelTask(@PathVariable Long taskId) {
        boolean cancelled = backgroundTaskService.cancelTask(taskId);
        if (!cancelled) {
            throw new TaskCancellationException("Task cannot be cancelled: " + taskId);
        }
    }

    /**
     * Request DTO for task submission.
     */
    public static class TaskSubmissionRequest {
        @NotBlank
        private String taskType;
        private String taskData;

        public String getTaskType() {
            return taskType;
        }

        public void setTaskType(String taskType) {
            this.taskType = taskType;
        }

        public String getTaskData() {
            return taskData;
        }

        public void setTaskData(String taskData) {
            this.taskData = taskData;
        }
    }

    /**
     * Exception thrown when a task is not found.
     */
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public static class TaskNotFoundException extends RuntimeException {
        public TaskNotFoundException(String message) {
            super(message);
        }
    }

    /**
     * Exception thrown when a task cannot be cancelled.
     */
    @ResponseStatus(HttpStatus.CONFLICT)
    public static class TaskCancellationException extends RuntimeException {
        public TaskCancellationException(String message) {
            super(message);
        }
    }
}
