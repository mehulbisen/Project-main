import React, {useState, useEffect} from 'react';

const API_BASE = (window.__API_BASE__ && window.__API_BASE__) || '/api'; // replaced at build or use proxy

export default function App(){
  const [students, setStudents] = useState([]);
  const [form, setForm] = useState({first_name:'', last_name:'', email:'', dob:'', enrollment_no:'', course:''});
  const [status, setStatus] = useState('');

  useEffect(()=> { fetchStudents(); }, []);

  async function fetchStudents(){
    try {
      const res = await fetch(`${API_BASE}/students`);
      const j = await res.json();
      setStudents(j);
    } catch(e) {
      console.error(e);
    }
  }

  async function onSubmit(e){
    e.preventDefault();
    setStatus('Submitting...');
    const res = await fetch(`${API_BASE}/students`, {
      method: 'POST',
      headers: {'Content-Type':'application/json'},
      body: JSON.stringify(form)
    });
    if (res.ok) {
      setForm({first_name:'', last_name:'', email:'', dob:'', enrollment_no:'', course:''});
      setStatus('Saved');
      fetchStudents();
    } else {
      const j = await res.json();
      setStatus(`Error: ${j.error || res.statusText}`);
    }
  }

  return (
    <div style={{maxWidth:800, margin:'0 auto', padding:20}}>
      <h1>Student Entry</h1>
      <form onSubmit={onSubmit} style={{display:'grid', gap:8}}>
        <input value={form.first_name} onChange={e=>setForm({...form, first_name:e.target.value})} placeholder="First name" required />
        <input value={form.last_name} onChange={e=>setForm({...form, last_name:e.target.value})} placeholder="Last name" required />
        <input value={form.email} onChange={e=>setForm({...form, email:e.target.value})} placeholder="Email" type="email" required />
        <input value={form.dob} onChange={e=>setForm({...form, dob:e.target.value})} placeholder="DOB (YYYY-MM-DD)" />
        <input value={form.enrollment_no} onChange={e=>setForm({...form, enrollment_no:e.target.value})} placeholder="Enrollment No" />
        <input value={form.course} onChange={e=>setForm({...form, course:e.target.value})} placeholder="Course" />
        <button type="submit">Save</button>
      </form>
      <div style={{marginTop:20}}><strong>{status}</strong></div>

      <h2>Students</h2>
      <table border="1" cellPadding="8" style={{width:'100%'}}>
        <thead><tr><th>ID</th><th>Name</th><th>Email</th><th>DOB</th><th>Enrollment</th><th>Course</th></tr></thead>
        <tbody>
          {students.map(s => (
            <tr key={s.id}>
              <td>{s.id}</td>
              <td>{s.first_name} {s.last_name}</td>
              <td>{s.email}</td>
              <td>{s.dob}</td>
              <td>{s.enrollment_no}</td>
              <td>{s.course}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
