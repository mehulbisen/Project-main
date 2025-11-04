CREATE TABLE events (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255),
  description TEXT
);

CREATE TABLE bookings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  event_id INT,
  user_name VARCHAR(255),
  user_email VARCHAR(255)
);

INSERT INTO events (title, description)
VALUES ('Tech Meetup', 'Learn AWS'), ('Music Night', 'Enjoy music!');
