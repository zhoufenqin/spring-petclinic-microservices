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

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repository for BackgroundTask entity.
 *
 * @author Spring Petclinic Team
 */
@Repository
public interface BackgroundTaskRepository extends JpaRepository<BackgroundTask, Long> {

    /**
     * Find all tasks with a specific status.
     *
     * @param status the task status
     * @return list of tasks with the given status
     */
    List<BackgroundTask> findByStatus(BackgroundTask.TaskStatus status);

    /**
     * Find all tasks of a specific type.
     *
     * @param taskType the task type
     * @return list of tasks of the given type
     */
    List<BackgroundTask> findByTaskType(String taskType);

    /**
     * Find all tasks with a specific status and type.
     *
     * @param status the task status
     * @param taskType the task type
     * @return list of matching tasks
     */
    List<BackgroundTask> findByStatusAndTaskType(BackgroundTask.TaskStatus status, String taskType);
}
