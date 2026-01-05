# Background Agent Implementation

## Overview

This implementation adds a background task processing system to the Spring Petclinic microservices application. The system enables asynchronous task execution with support for:

- Multiple background tasks executing simultaneously
- Task delegation to background workers
- Concurrent task execution using a thread pool
- Task status tracking and management
- Retry mechanisms for failed tasks

## Architecture

### Components

1. **BackgroundTask Entity** - Represents a task that can be executed asynchronously
   - Stores task metadata (type, data, status, timestamps)
   - Supports different task statuses: PENDING, RUNNING, COMPLETED, FAILED, CANCELLED

2. **BackgroundTaskRepository** - JPA repository for task persistence
   - Provides queries for finding tasks by status and type

3. **TaskExecutor Interface** - Contract for implementing custom task handlers
   - Each executor handles a specific task type
   - Executors register themselves with the BackgroundTaskService

4. **BackgroundTaskService** - Core service managing task lifecycle
   - Submits new tasks
   - Executes tasks asynchronously using @Async
   - Processes pending tasks via scheduled job
   - Manages task status transitions

5. **AsyncConfig** - Spring configuration for async execution
   - Configures thread pool for concurrent task execution
   - Pool size: 5 core threads, 10 max threads, 100 queue capacity

6. **BackgroundTaskResource** - REST controller for task management
   - Submit tasks: `POST /background-tasks`
   - Get task status: `GET /background-tasks/{id}`
   - List all tasks: `GET /background-tasks`
   - List tasks by status: `GET /background-tasks/status/{status}`
   - Cancel task: `DELETE /background-tasks/{id}`

## Key Features

### Concurrent Task Execution

Multiple tasks can execute simultaneously thanks to:
- Thread pool configuration with multiple worker threads
- Async execution using Spring's @Async annotation
- Scheduled processor that picks up pending tasks every 5 seconds

### Task Delegation

Tasks are delegated to background workers through:
1. Task submission via REST API or service method
2. Persistence to database with PENDING status
3. Scheduled processor detects pending tasks
4. Tasks are delegated to async worker threads
5. Appropriate TaskExecutor handles the task based on type

### Relationship Between Components

```
[Client] 
   ↓ (submits task)
[BackgroundTaskResource]
   ↓ (calls)
[BackgroundTaskService]
   ↓ (persists)
[BackgroundTask Entity]
   ↓ (saved to)
[Database]

[Scheduled Processor] (every 5 seconds)
   ↓ (queries pending tasks)
[BackgroundTaskService]
   ↓ (delegates to)
[@Async Worker Pool]
   ↓ (executes via)
[TaskExecutor Implementation]
```

## Usage Examples

### Submitting a Task

```bash
curl -X POST http://localhost:8080/background-tasks \
  -H "Content-Type: application/json" \
  -d '{
    "taskType": "VISIT_NOTIFICATION",
    "taskData": "{\"visitId\": 123}"
  }'
```

### Checking Task Status

```bash
curl http://localhost:8080/background-tasks/1
```

### Listing All Pending Tasks

```bash
curl http://localhost:8080/background-tasks/status/PENDING
```

### Cancelling a Task

```bash
curl -X DELETE http://localhost:8080/background-tasks/1
```

## Implementing Custom Task Executors

To add a new background task type:

1. Create a class implementing `TaskExecutor` interface
2. Annotate with `@Component`
3. Inject `BackgroundTaskService` and register in `@PostConstruct`
4. Implement the `execute()` method with your task logic
5. Return a unique task type string

Example:

```java
@Component
@RequiredArgsConstructor
public class MyCustomExecutor implements TaskExecutor {
    
    private final BackgroundTaskService backgroundTaskService;
    
    @PostConstruct
    public void init() {
        backgroundTaskService.registerExecutor(this);
    }
    
    @Override
    public void execute(BackgroundTask task) {
        // Your task logic here
    }
    
    @Override
    public String getTaskType() {
        return "MY_CUSTOM_TASK";
    }
}
```

## Database Schema

The implementation adds a `background_tasks` table:

- **MySQL**: Uses AUTO_INCREMENT for ID generation
- **HSQLDB**: Uses IDENTITY for ID generation

Both support the same fields:
- id, task_type, task_data, status
- created_at, started_at, completed_at
- error_message, retry_count

## Testing

Unit tests are provided in `BackgroundTaskServiceTest` covering:
- Task submission
- Task retrieval
- Task cancellation
- Status filtering
- Executor registration

## Integration with Existing Services

The background task system is implemented in the visits-service module as a demonstration. It can be:

1. Used directly in visits-service for async visit processing
2. Extracted into a shared library for use across all microservices
3. Enhanced with additional features like:
   - Task priorities
   - Scheduled/delayed execution
   - Task dependencies
   - Progress tracking
   - Result storage

## Performance Considerations

- Thread pool size can be adjusted in `AsyncConfig`
- Scheduled processor interval (default 5s) can be tuned
- Database queries use indexes on status and task_type
- Consider adding task expiration/cleanup for long-running systems
