package org.springframework.samples.petclinic.visits.background;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class BackgroundTaskServiceTest {

    @Mock
    private BackgroundTaskRepository taskRepository;

    private BackgroundTaskService backgroundTaskService;

    @BeforeEach
    void setUp() {
        backgroundTaskService = new BackgroundTaskService(taskRepository);
    }

    @Test
    void shouldSubmitTask() {
        // Given
        String taskType = "TEST_TASK";
        String taskData = "test data";
        BackgroundTask savedTask = BackgroundTask.builder()
            .id(1L)
            .taskType(taskType)
            .taskData(taskData)
            .status(BackgroundTask.TaskStatus.PENDING)
            .build();

        given(taskRepository.save(any(BackgroundTask.class))).willReturn(savedTask);

        // When
        BackgroundTask result = backgroundTaskService.submitTask(taskType, taskData);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getId()).isEqualTo(1L);
        assertThat(result.getTaskType()).isEqualTo(taskType);
        assertThat(result.getTaskData()).isEqualTo(taskData);
        assertThat(result.getStatus()).isEqualTo(BackgroundTask.TaskStatus.PENDING);

        ArgumentCaptor<BackgroundTask> taskCaptor = ArgumentCaptor.forClass(BackgroundTask.class);
        verify(taskRepository).save(taskCaptor.capture());
        BackgroundTask capturedTask = taskCaptor.getValue();
        assertThat(capturedTask.getTaskType()).isEqualTo(taskType);
        assertThat(capturedTask.getTaskData()).isEqualTo(taskData);
    }

    @Test
    void shouldGetTaskById() {
        // Given
        Long taskId = 1L;
        BackgroundTask task = BackgroundTask.builder()
            .id(taskId)
            .taskType("TEST_TASK")
            .status(BackgroundTask.TaskStatus.PENDING)
            .build();

        given(taskRepository.findById(taskId)).willReturn(Optional.of(task));

        // When
        BackgroundTask result = backgroundTaskService.getTask(taskId);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getId()).isEqualTo(taskId);
        verify(taskRepository).findById(taskId);
    }

    @Test
    void shouldGetAllTasks() {
        // Given
        List<BackgroundTask> tasks = Arrays.asList(
            BackgroundTask.builder().id(1L).taskType("TASK1").status(BackgroundTask.TaskStatus.PENDING).build(),
            BackgroundTask.builder().id(2L).taskType("TASK2").status(BackgroundTask.TaskStatus.RUNNING).build()
        );

        given(taskRepository.findAll()).willReturn(tasks);

        // When
        List<BackgroundTask> result = backgroundTaskService.getAllTasks();

        // Then
        assertThat(result).hasSize(2);
        verify(taskRepository).findAll();
    }

    @Test
    void shouldGetTasksByStatus() {
        // Given
        BackgroundTask.TaskStatus status = BackgroundTask.TaskStatus.PENDING;
        List<BackgroundTask> tasks = Arrays.asList(
            BackgroundTask.builder().id(1L).taskType("TASK1").status(status).build(),
            BackgroundTask.builder().id(2L).taskType("TASK2").status(status).build()
        );

        given(taskRepository.findByStatus(status)).willReturn(tasks);

        // When
        List<BackgroundTask> result = backgroundTaskService.getTasksByStatus(status);

        // Then
        assertThat(result).hasSize(2);
        assertThat(result).allMatch(task -> task.getStatus() == status);
        verify(taskRepository).findByStatus(status);
    }

    @Test
    void shouldCancelPendingTask() {
        // Given
        Long taskId = 1L;
        BackgroundTask task = BackgroundTask.builder()
            .id(taskId)
            .taskType("TEST_TASK")
            .status(BackgroundTask.TaskStatus.PENDING)
            .build();

        given(taskRepository.findById(taskId)).willReturn(Optional.of(task));
        given(taskRepository.save(any(BackgroundTask.class))).willReturn(task);

        // When
        boolean result = backgroundTaskService.cancelTask(taskId);

        // Then
        assertThat(result).isTrue();
        verify(taskRepository).save(task);
        assertThat(task.getStatus()).isEqualTo(BackgroundTask.TaskStatus.CANCELLED);
    }

    @Test
    void shouldNotCancelRunningTask() {
        // Given
        Long taskId = 1L;
        BackgroundTask task = BackgroundTask.builder()
            .id(taskId)
            .taskType("TEST_TASK")
            .status(BackgroundTask.TaskStatus.RUNNING)
            .build();

        given(taskRepository.findById(taskId)).willReturn(Optional.of(task));

        // When
        boolean result = backgroundTaskService.cancelTask(taskId);

        // Then
        assertThat(result).isFalse();
        verify(taskRepository, never()).save(any());
    }

    @Test
    void shouldRegisterExecutor() {
        // Given
        TaskExecutor executor = new TaskExecutor() {
            @Override
            public void execute(BackgroundTask task) {
                // no-op
            }

            @Override
            public String getTaskType() {
                return "TEST_EXECUTOR";
            }
        };

        // When
        backgroundTaskService.registerExecutor(executor);

        // Then - no exception should be thrown
    }
}
