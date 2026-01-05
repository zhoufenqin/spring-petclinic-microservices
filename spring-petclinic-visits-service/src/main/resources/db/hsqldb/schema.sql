DROP TABLE visits IF EXISTS;
DROP TABLE background_tasks IF EXISTS;

CREATE TABLE visits (
  id          INTEGER IDENTITY PRIMARY KEY,
  pet_id      INTEGER NOT NULL,
  visit_date  DATE,
  description VARCHAR(8192)
);

CREATE INDEX visits_pet_id ON visits (pet_id);

CREATE TABLE background_tasks (
  id BIGINT IDENTITY PRIMARY KEY,
  task_type VARCHAR(255) NOT NULL,
  task_data LONGVARCHAR,
  status VARCHAR(50) NOT NULL,
  created_at TIMESTAMP NOT NULL,
  started_at TIMESTAMP,
  completed_at TIMESTAMP,
  error_message LONGVARCHAR,
  retry_count INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX idx_bg_task_status ON background_tasks (status);
CREATE INDEX idx_bg_task_type ON background_tasks (task_type);
