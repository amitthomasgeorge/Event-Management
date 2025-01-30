const express = require("express");
const Razorpay = require('razorpay');
const WebSocket = require('ws');
const { dirname } = require("path");
var con = require("./web1");
const cors  = require('cors');
const app=express();
require("dotenv").config();
app.use(cors());
var bodypar=require("body-parser");
const { error } = require("console");
const path = require("path");
const session = require('express-session');
app.use(bodypar.json());
const authRoutes = require("./routes/auth");
app.use(bodypar.urlencoded({ extended : true }));
app.use(session({
    secret: 'your_secret_key',
    resave: false,
    saveUninitialized: true,
}));

const server = app.listen(3000,()=>{
  console.log('server running');
});

app.use("/api/auth", authRoutes);

const wss = new WebSocket.Server({server});


wss.on('connection', (ws) => {
  console.log('New client connected');

  // Handle incoming booking request
  ws.on('message', (message) => {

    const data = JSON.parse(message);

    console.log(data);
    // Assume we receive a request like { action: 'book', ticketId: 1 }
    if (data.action === 'book') {
      const id = data.id;
      const quant=data.quantity;
      // Check if the ticket is available in the database
      con.query('SELECT * FROM organization WHERE id = ? AND ticket>0', [id], (err, results) => {
        if (err) {
          ws.send(JSON.stringify({ success: false, message: 'Database error' }));
          return;
        }

        if (results.length > 0) {
          // Mark ticket as booked
          con.query('UPDATE organization SET ticket = ticket-?  WHERE id = ?', [quant,id], (err) => {
            if (err) {
              ws.send(JSON.stringify({ success: false, message: 'Booking failed' }));
              return;
            }

            // Notify all connected clients of the updated booking status
            wss.clients.forEach(client => {
              if (client.readyState === WebSocket.OPEN) {
                client.send(JSON.stringify({ action: 'update', id, status: 'booked' }));
              }
            });

            ws.send(JSON.stringify({ success: true, message: 'Ticket booked successfully' }));
          });
        } else {
          ws.send(JSON.stringify({ success: false, message: 'Ticket unavailable' }));
        }
      });
    }
    else if (data.action === 'cancel') {
      const id = data.id;
      const user=data.user;
      const bid=data.bid;
      // Check if the ticket is available in the database
      con.query('SELECT * FROM user1 WHERE wid = ? AND username=? and bid=?', [id,user,bid], (err, results) => {
        if (err) {
          ws.send(JSON.stringify({ success: false, message: 'Database error' }));
          return;
        }

        if (results.length > 0) {
          console.log(results[0]['quantity']);
          // Mark ticket as booked
          con.query('UPDATE organization SET ticket = ticket+?  WHERE id = ?', [results[0]['quantity'],id,], (err) => {
            if (err) {
              ws.send(JSON.stringify({ success: false, message: 'Cancel failed' }));
              return;
            }
            

            // Notify all connected clients of the updated booking status
            wss.clients.forEach(client => {
              if (client.readyState === WebSocket.OPEN) {
                client.send(JSON.stringify({ action: 'cancel', id, status: 'cancelled' }));
              }
            });

            ws.send(JSON.stringify({ success: true, message: 'Ticket cancelled successfully' }));
          });

          con.query('DELETE from user1 WHERE wid=? and username=? and bid=?', [id,user,bid], (err) => {
            if (err) {
              ws.send(JSON.stringify({ success: false, message: 'Booking failed' }));
              return;
            }
            

            // Notify all connected clients of the updated booking status
            wss.clients.forEach(client => {
              if (client.readyState === WebSocket.OPEN) {
                client.send(JSON.stringify({ action: 'cancel', id, status: 'cancelled' }));
              }
            });

            ws.send(JSON.stringify({ success: true, message: 'Ticket booked successfully' }));
          });
        } else {
          ws.send(JSON.stringify({ success: false, message: 'Ticket unavailable' }));
        }
      });
    }

    else if (data.action === 'cancelevent') {
      const id = data.id;
      const user=data.user;
      // Check if the ticket is available in the database
      con.query('SELECT * FROM organization WHERE id = ? AND username=?', [id,user], (err, results) => {
        if (err) {
          ws.send(JSON.stringify({ success: false, message: 'Database error' }));
          return;
        }

        if (results.length > 0) {
      
          // Mark ticket as booked
          con.query('DELETE from user1 WHERE wid=?', [id], (err) => {
            if (err) {
              ws.send(JSON.stringify({ success: false, message: 'Cancel failed' }));
              return;
            }
            

            // Notify all connected clients of the updated booking status
            wss.clients.forEach(client => {
              if (client.readyState === WebSocket.OPEN) {
                client.send(JSON.stringify({ action: 'cancelevent', id, status: 'cancelled' }));
              }
            });

            ws.send(JSON.stringify({ success: true, message: 'Ticket cancelled successfully' }));
          });

          con.query('DELETE from organization WHERE id=? and username=?', [id,user], (err) => {
            if (err) {
              ws.send(JSON.stringify({ success: false, message: 'Booking failed' }));
              return;
            }
            

            // Notify all connected clients of the updated booking status
            wss.clients.forEach(client => {
              if (client.readyState === WebSocket.OPEN) {
                client.send(JSON.stringify({ action: 'cancelevent', id, status: 'cancelled' }));
              }
            });

            ws.send(JSON.stringify({ success: true, message: 'Ticket booked successfully' }));
          });
        } else {
          ws.send(JSON.stringify({ success: false, message: 'Ticket unavailable' }));
        }
      });
    }

    else if (data.action === 'cancelorg') {
      const Organiser=data.Organiser;
      const user=data.user;
      // Check if the ticket is available in the database
      con.query('SELECT * FROM Role WHERE  username=?', [user], (err, results) => {
        if (err) {
          ws.send(JSON.stringify({ success: false, message: 'Database error' }));
          return;
        }

        if (results.length > 0) {
      
          // Mark ticket as booked
          con.query('DELETE from organization WHERE username=?', [user], (err) => {
            if (err) {
              ws.send(JSON.stringify({ success: false, message: 'Cancel failed' }));
              return;
            }
            

            // Notify all connected clients of the updated booking status
            wss.clients.forEach(client => {
              if (client.readyState === WebSocket.OPEN) {
                client.send(JSON.stringify({ action: 'cancelorg', user, status: 'cancelled' }));
              }
            });

            ws.send(JSON.stringify({ success: true, message: 'Ticket cancelled successfully' }));
          });

          //
          con.query('DELETE from user1 WHERE Organiser=?', [Organiser], (err) => {
            if (err) {
              ws.send(JSON.stringify({ success: false, message: 'Cancel failed' }));
              return;
            }
            

            // Notify all connected clients of the updated booking status
            wss.clients.forEach(client => {
              if (client.readyState === WebSocket.OPEN) {
                client.send(JSON.stringify({ action: 'cancelorg', user, status: 'cancelled' }));
              }
            });

            ws.send(JSON.stringify({ success: true, message: 'Ticket cancelled successfully' }));
          });
          //


          con.query('DELETE from Role WHERE  username=?', [user], (err) => {
            if (err) {
              ws.send(JSON.stringify({ success: false, message: 'Booking failed' }));
              return;
            }
            

            // Notify all connected clients of the updated booking status
            wss.clients.forEach(client => {
              if (client.readyState === WebSocket.OPEN) {
                client.send(JSON.stringify({ action: 'cancelorg', user, status: 'cancelled' }));
              }
            });

            ws.send(JSON.stringify({ success: true, message: 'Ticket booked successfully' }));
          });
        } else {
          ws.send(JSON.stringify({ success: false, message: 'Ticket unavailable' }));
        }
      });
    }
////////////////

else if (data.action === 'canceluser') {
  
  const username=data.user;
  con.query(
    'SELECT wid, SUM(quantity) as ticket_count FROM user1 WHERE username = ? GROUP BY wid;',
    [username],
    (err, results) => {
      if (err) {
        console.error('Error counting tickets:', err);
        wss.send(JSON.stringify({ error: 'Error counting tickets.' }));
        return;
      }
      results.forEach((row) => {
        con.query(
          'UPDATE organization SET ticket = ticket + ? WHERE id = ?',
          [row.ticket_count, row.wid],
          (err, updateResult) => {
            if (err) {
              console.error('Error updating ticket count:', err);
            } else {
              console.log(`Ticket count updated for wid ${row.wid}.`);
            }
          }
        );
      });
  
      con.query(
        'DELETE FROM Role WHERE username = ?',
        [username],
        (err, deleteResult) => {
          if (err) {
            console.error('Error deleting user:', err);
          } else {
            console.log(`User ${username} deleted successfully.`);
          }
        }
      );
      con.query(
        'DELETE FROM user1 WHERE username = ?',
        [username],
        (err, deleteResult) => {
          if (err) {
            console.error('Error deleting user:', err);
            wss.send(JSON.stringify({ error: 'Error deleting user.' }));
          } else {
            console.log(`User ${username} deleted successfully.`);
            wss.clients.forEach(client => {
              if (client.readyState === WebSocket.OPEN) {
                client.send(JSON.stringify({ action: 'canceluser', username, status: 'cancelled' }));
              }
            })
          }
        }
      );
    }
  );
  
  }

  });

  // Close connection
  ws.on('close', () => {
    console.log('Client disconnected');
  });
});





const razorpay = new Razorpay({
  key_id: 'rzp_test_7gBCnoEsPrcvyr', // Replace with your Razorpay key
  key_secret: '7dxd04o7px89T9esNgYci9Aq' // Replace with your Razorpay secret
});

app.post('/create-order', async (req, res) => {
  try {
    const {amount} = req.body;
    console.log(amount);// Amount in rupees
    const order = await razorpay.orders.create({
      amount: amount * 100,  // Convert amount to paise
      currency: 'INR',
      receipt: `receipt_${Date.now()}`,
      payment_capture: 1,
    });
    res.json({
      id: order.id,
      currency: order.currency,
      amount: order.amount,
    });
  } catch (error) {
    console.error('Error creating order:', error);
    res.status(500).send('Internal Server Error');
  }
});

// Route to verify payment (Handle success/failure callback)
app.post('/verify-payment', (req, res) => {
  const { payment_id, order_id, signature } = req.body;
  console.log(payment_id);
  const expected_signature = razorpay.utility.verifyPaymentSignature({
    payment_id,
    order_id,
    signature,
  });

  if (expected_signature === signature) {
    res.send('Payment Successful');
  } else {
    res.status(400).send('Payment Verification Failed');
  }
});



app.post('/submit',(req,res)=>{
    const{eventname,Location,Price,Description,Category,Time,Date,Organiser,ticket,username}= req.body;
    const sql = `INSERT INTO organization (eventname,Location,Price,Description,Category,Time,Date,Organiser,ticket,username) VALUES (?, ?, ?, ?, ?, ?, ?, ?,?,?)`;
    const values = [eventname,Location,Price,Description,Category,Time,Date,Organiser,ticket,username];
    
    con.query(sql, values, (err, result) => {
      if (err) {
        console.error('Error executing query:', err);
        return;
      }
    });
});

app.post('/booked',(req,res)=>{
  const{username,wid,quantity,Organiser}= req.body;
  const sql = `INSERT INTO user1 (wid,username,quantity,Organiser) VALUES (?,?,?,?)`;
  const values = [wid,username,quantity,Organiser];
  
  con.query(sql, values, (err, result) => {
    if (err) {
      console.error('Error executing query:', err);
      return;
    }
  });
});


app.post('/update',(req,res)=>{
  const{eventname,Location,Price,Description,Category,Time,Date,Organiser,id,ticket}= req.body;
  const sql = `UPDATE organization SET eventname = ?,Location = ?, Price = ?,Description= ?,Category=?,Time=?,Date=?,Organiser=?,ticket=? WHERE id=?`;
  const values = [eventname,Location,Price,Description,Category,Time,Date,Organiser,ticket,id];
  
  con.query(sql, values, (err, result) => {
    if (err) {
      console.error('Error executing query:', err);
      return;
    }
  });
});


app.post('/delete',(req,res)=>{
  const{id}= req.body;
  const sql = `DELETE from organization WHERE id=?`;
  const pid= id;
  
  con.query(sql, [pid], (err, result) => {
    if (err) {
      console.error('Error executing query:', err);
      return;
    }
  });
});



app.get('/fetch',(req,res)=>{
  var values=[]
  const Location=req.query.Location;
  const Category=req.query.Category;
  const username=req.query.username;
var query='';
if(Location!=null || Category!=null)
{
  if(Location!=null && Category!=null)
    query='Select * from organization WHERE Location=? and Category=? and username=?';
  else
  query='Select * from organization WHERE Location=? or Category=? and username=?';
}
else
{
  query='Select * from organization WHERE username=?';
}
if(Location!=null || Category!=null)
{
  values=[Location,Category,username];
}
else
{
  values=[username];
}

con.query(query,values,(err,result)=>{
  if (err) {
    console.error('Error executing query:', err);
    return;
  }
  res.json(result);
})
});

app.get('/fetchdropadmin',(req,res)=>{
  var values=[]
  const Location=req.query.Location;
  const Category=req.query.Category;
var query='';
if(Location!=null || Category!=null)
{
  if(Location!=null && Category!=null)
    query='Select * from organization WHERE Location=? and Category=?';
  else
  query='Select * from organization WHERE Location=? or Category=?';
}
else
{
  query='Select * from organization';
}
if(Location!=null || Category!=null)
{
  values=[Location,Category];
}
else
{
  values=[username];
}

con.query(query,values,(err,result)=>{
  if (err) {
    console.error('Error executing query:', err);
    return;
  }
  res.json(result);
})
});


app.get('/fetchuser',(req,res)=>{
  const {Location,Category} = req.query;
  var query='';
  if(Location!=null || Category!=null)
  {
    if(Location!=null && Category!=null)
      query='Select * from organization WHERE Location=? and Category=?';
    else
    query='Select * from organization WHERE Location=? or Category=?';
  }
  else
  {
    query='Select * from organization WHERE Date >= CURDATE() and ticket>0';
  }
  const values=[Location,Category];
  con.query(query,values,(err,result)=>{
    if (err) {
      console.error('Error executing query:', err);
      return;
    }
    res.json(result);
  })
  });

  app.get('/fetchOrgAdmin',(req,res)=>{

    const query="Select Count(username) as Orgcount from Role WHERE type='Organization'";
    con.query(query,(err,result)=>{
      if (err) {
        console.error('Error executing query:', err);
        return;
      }
      res.json(result);
    })
    });

    app.get('/fetchOrganization',(req,res)=>{

      const query="Select Distinct(name) as Organiser,username from Role where type='Organization' ";
      con.query(query,(err,result)=>{
        if (err) {
          console.error('Error executing query:', err);
          return;
        }
        res.json(result);
      })
      });


      app.get('/fetchUserevent',(req,res)=>{
        const username=req.query.username;
        const query="Select organization.eventname as eventname,user1.wid as eventid,user1.bid as bid from organization,user1 WHERE organization.id=user1.wid and user1.username=?";
        con.query(query,[username],(err,result)=>{
          if (err) {
            console.error('Error executing query:', err);
            return;
          }
          res.json(result);
        })
        });


      app.get('/fetchUserDash',(req,res)=>{

        const query="Select Distinct(username) as username from Role WHERE type='User'";
        con.query(query,(err,result)=>{
          if (err) {
            console.error('Error executing query:', err);
            return;
          }
          res.json(result);
        })
        });


        app.get('/fetchOrgevent',(req,res)=>{
          const username = req.query.username;
          console.log(username);
          const query="Select id,eventname,Location,Price,Time  from organization WHERE username=?";
          con.query(query,[username],(err,result)=>{
            if (err) {
              console.error('Error executing query:', err);
              return;
            }
            res.json(result);
          })
          });



    app.get('/fetchUserAdmin',(req,res)=>{

      const query="Select Count(username) as Usercount from Role WHERE type='User'";
      con.query(query,(err,result)=>{
        if (err) {
          console.error('Error executing query:', err);
          return;
        }
        res.json(result);
      })
      });


  app.get('/bookings',(req,res)=>{
    const username  = req.query.username;
    console.log(username);
    const  query='Select user1.wid as eventid,eventname,Location,user1.Organiser as Organiser,user1.username as user,user1.bid as bid,quantity from organization,user1 where organization.id=user1.wid and user1.username=?';
    const values=[username];
    con.query(query,values,(err,result)=>{
      if (err) {
        console.error('Error executing query:', err);
        return;
      }
      res.json(result);
    })
    });
  

// API endpoint to get names
app.get('/location', (req, res) => {
  const username=req.query.username;
  const query='SELECT Distinct(Location) FROM organization WHERE username=?';
  con.query(query,[username],(err, results) => {
    if (err) {
      console.error('Error executing query:', err);
      res.status(500).send('Error fetching data');
      return;
    }

    // Send the results as JSON
    res.json(results.map(row => row.Location)); // Return only the names
  });
});

app.get('/category', (req, res) => {
  const username=req.query.username;
  const query ='SELECT Distinct(Category) FROM organization WHERE username=?';
  con.query(query,[username],(err,results) => {
    if (err) {
      console.error('Error executing query:', err);
      res.status(500).send('Error fetching data');
      return;
    }

    // Send the results as JSON
    res.json(results.map(row => row.Category)); // Return only the names
  });
});

app.get('/locationadmin', (req, res) => {
  const query='SELECT Distinct(Location) FROM organization';
  con.query(query,(err, results) => {
    if (err) {
      console.error('Error executing query:', err);
      res.status(500).send('Error fetching data');
      return;
    }

    // Send the results as JSON
    res.json(results.map(row => row.Location)); // Return only the names
  });
});

app.get('/categoryadmin', (req, res) => {
  const query ='SELECT Distinct(Category) FROM organization';
  con.query(query,(err,results) => {
    if (err) {
      console.error('Error executing query:', err);
      res.status(500).send('Error fetching data');
      return;
    }

    // Send the results as JSON
    res.json(results.map(row => row.Category)); // Return only the names
  });
});


