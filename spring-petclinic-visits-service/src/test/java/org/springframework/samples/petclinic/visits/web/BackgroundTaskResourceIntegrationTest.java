package org.springframework.samples.petclinic.visits.web;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.samples.petclinic.visits.background.BackgroundTask;
import org.springframework.samples.petclinic.visits.background.BackgroundTaskRepository;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import com.fasterxml.jackson.databind.ObjectMapper;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Integration test for the Background Task REST API.
 * Tests the end-to-end functionality of background task submission and management.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class BackgroundTaskResourceIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private BackgroundTaskRepository taskRepository;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void shouldSubmitAndRetrieveTask() throws Exception {
        // Submit a new task
        String requestBody = """
            {
                "taskType": "VISIT_NOTIFICATION",
                "taskData": "{\\"visitId\\": 123}"
            }
            """;

        MvcResult result = mockMvc.perform(post("/background-tasks")
                .contentType(MediaType.APPLICATION_JSON)
                .content(requestBody))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.id").exists())
            .andExpect(jsonPath("$.taskType").value("VISIT_NOTIFICATION"))
            .andExpect(jsonPath("$.status").value("PENDING"))
            .andReturn();

        // Extract task ID from response
        String responseBody = result.getResponse().getContentAsString();
        BackgroundTask task = objectMapper.readValue(responseBody, BackgroundTask.class);
        Long taskId = task.getId();

        // Retrieve the task
        mockMvc.perform(get("/background-tasks/" + taskId))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.id").value(taskId))
            .andExpect(jsonPath("$.taskType").value("VISIT_NOTIFICATION"));
    }

    @Test
    void shouldListAllTasks() throws Exception {
        // Submit a task
        String requestBody = """
            {
                "taskType": "TEST_TASK",
                "taskData": "test data"
            }
            """;

        mockMvc.perform(post("/background-tasks")
                .contentType(MediaType.APPLICATION_JSON)
                .content(requestBody))
            .andExpect(status().isCreated());

        // List all tasks
        mockMvc.perform(get("/background-tasks"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$").isArray());
    }

    @Test
    void shouldCancelTask() throws Exception {
        // Submit a task
        String requestBody = """
            {
                "taskType": "VISIT_NOTIFICATION",
                "taskData": "test"
            }
            """;

        MvcResult result = mockMvc.perform(post("/background-tasks")
                .contentType(MediaType.APPLICATION_JSON)
                .content(requestBody))
            .andExpect(status().isCreated())
            .andReturn();

        String responseBody = result.getResponse().getContentAsString();
        BackgroundTask task = objectMapper.readValue(responseBody, BackgroundTask.class);
        Long taskId = task.getId();

        // Cancel the task
        mockMvc.perform(delete("/background-tasks/" + taskId))
            .andExpect(status().isNoContent());

        // Verify task is cancelled
        BackgroundTask cancelledTask = taskRepository.findById(taskId).orElse(null);
        assertThat(cancelledTask).isNotNull();
        assertThat(cancelledTask.getStatus()).isEqualTo(BackgroundTask.TaskStatus.CANCELLED);
    }

    @Test
    void shouldReturn404ForNonExistentTask() throws Exception {
        mockMvc.perform(get("/background-tasks/999999"))
            .andExpect(status().isNotFound());
    }

    @Test
    void shouldFilterTasksByStatus() throws Exception {
        // Submit a task
        String requestBody = """
            {
                "taskType": "TEST_TASK",
                "taskData": "test"
            }
            """;

        mockMvc.perform(post("/background-tasks")
                .contentType(MediaType.APPLICATION_JSON)
                .content(requestBody))
            .andExpect(status().isCreated());

        // Get tasks by status
        mockMvc.perform(get("/background-tasks/status/PENDING"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$").isArray());
    }
}
