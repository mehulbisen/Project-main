import React, { useState, useEffect } from "react";

function App() {
  const [events, setEvents] = useState([]);
  const [title, setTitle] = useState("");

  // 👇 change this to your backend API endpoint
  const API_BASE = process.env.REACT_APP_API_BASE_URL || "http://localhost:8080";

  useEffect(() => {
    fetch(`${API_BASE}/events`)
      .then((res) => res.json())
      .then((data) => setEvents(data))
      .catch((err) => console.error("Error fetching events:", err));
  }, [API_BASE]);

  const addEvent = () => {
    if (!title) return alert("Enter event title");
    fetch(`${API_BASE}/events`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ title }),
    })
      .then(() => {
        setTitle("");
        return fetch(`${API_BASE}/events`);
      })
      .then((res) => res.json())
      .then((data) => setEvents(data))
      .catch((err) => console.error("Error adding event:", err));
  };

  return (
    <div style={{ margin: "40px" }}>
      <h1>🎫 Event Booking</h1>
      <input
        placeholder="Event title"
        value={title}
        onChange={(e) => setTitle(e.target.value)}
      />
      <button onClick={addEvent}>Add Event</button>

      <h3>Event List:</h3>
      <ul>
        {events.map((e) => (
          <li key={e.id}>{e.title}</li>
        ))}
      </ul>
    </div>
  );
}

export default App;
