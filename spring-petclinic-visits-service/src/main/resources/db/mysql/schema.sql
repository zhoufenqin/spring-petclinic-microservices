-- CREATE DATABASE IF NOT EXISTS petclinic;
-- GRANT ALL PRIVILEGES ON petclinic.* TO pc@localhost IDENTIFIED BY 'pc';

-- USE petclinic;

CREATE TABLE IF NOT EXISTS visits (
  id INT(4) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  pet_id INT(4) UNSIGNED NOT NULL,
  visit_date DATE,
  description VARCHAR(8192),
  FOREIGN KEY (pet_id) REFERENCES pets(id)
) engine=InnoDB;

CREATE TABLE IF NOT EXISTS background_tasks (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  task_type VARCHAR(255) NOT NULL,
  task_data TEXT,
  status VARCHAR(50) NOT NULL,
  created_at DATETIME NOT NULL,
  started_at DATETIME,
  completed_at DATETIME,
  error_message TEXT,
  retry_count INT NOT NULL DEFAULT 0,
  INDEX idx_status (status),
  INDEX idx_task_type (task_type)
) engine=InnoDB;
