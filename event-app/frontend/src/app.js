// src/App.js
import React, {useEffect, useState} from 'react';

export default function App(){
  const [events, setEvents] = useState([]);
  useEffect(()=> {
    fetch('/api/events').then(r=>r.json()).then(setEvents);
  }, []);
  return (
    <div style={{padding:20}}>
      <h1>Events</h1>
      {events.length===0 && <div>No events</div>}
      <ul>
        {events.map(e => (
          <li key={e.id}>
            <strong>{e.title}</strong> — {new Date(e.start_time).toLocaleString()}
            <div>{e.description}</div>
          </li>
        ))}
      </ul>
    </div>
  );
}
