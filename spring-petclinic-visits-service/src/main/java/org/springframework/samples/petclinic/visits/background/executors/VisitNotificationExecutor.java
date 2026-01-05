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
package org.springframework.samples.petclinic.visits.background.executors;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.samples.petclinic.visits.background.BackgroundTask;
import org.springframework.samples.petclinic.visits.background.BackgroundTaskService;
import org.springframework.samples.petclinic.visits.background.TaskExecutor;
import org.springframework.samples.petclinic.visits.model.VisitRepository;
import org.springframework.stereotype.Component;

import jakarta.annotation.PostConstruct;

/**
 * Example task executor for visit notification tasks.
 * This demonstrates how to implement a custom background task executor.
 *
 * @author Spring Petclinic Team
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class VisitNotificationExecutor implements TaskExecutor {

    private final BackgroundTaskService backgroundTaskService;
    private final VisitRepository visitRepository;

    @PostConstruct
    public void init() {
        backgroundTaskService.registerExecutor(this);
    }

    @Override
    public void execute(BackgroundTask task) {
        log.info("Executing visit notification task: {}", task.getId());

        // Simulate notification processing
        try {
            // In a real implementation, this would send notifications
            // For now, we'll just simulate some work
            Thread.sleep(2000);
            log.info("Visit notification sent successfully for task: {}", task.getId());
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RuntimeException("Task interrupted", e);
        }
    }

    @Override
    public String getTaskType() {
        return "VISIT_NOTIFICATION";
    }
}
