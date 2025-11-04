import React, { useEffect, useState } from "react";

export default function App() {
  const [events, setEvents] = useState([]);
  const [form, setForm] = useState({ event_id: "", user_name: "", user_email: "" });

  useEffect(() => {
    fetch("/api/events").then(r => r.json()).then(setEvents);
  }, []);

  async function book(e) {
    e.preventDefault();
    await fetch("/api/book", { method: "POST", headers: { "Content-Type": "application/json" },
      body: JSON.stringify(form) });
    alert("Booking created");
  }

  return (
    <div style={{ padding: 20 }}>
      <h1>Events</h1>
      <ul>
        {events.map(ev => (
          <li key={ev.id}>
            {ev.title} <button onClick={() => setForm({ ...form, event_id: ev.id })}>Book</button>
          </li>
        ))}
      </ul>
      <form onSubmit={book}>
        <input placeholder="Name" onChange={e => setForm({ ...form, user_name: e.target.value })} />
        <input placeholder="Email" onChange={e => setForm({ ...form, user_email: e.target.value })} />
        <button>Submit</button>
      </form>
    </div>
  );
}
