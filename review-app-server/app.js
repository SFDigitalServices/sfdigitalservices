const express = require('express')
const app = express()
const port = process.env.PORT || 3333
const path = require('path')
const public = path.join(__dirname, '../public');


app.get('/', (req, res) => {
  res.sendFile(path.join(public, 'index.html'))
})

app.use('/', express.static(public))

app.listen(port, () => {
  console.log(`app listening at http://localhost:${port}`)
})