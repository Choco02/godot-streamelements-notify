const { readFileSync, readdirSync, writeFileSync } = require('fs')
// JWT is available here: https://streamelements.com/dashboard/account/channels
const files = readdirSync('.')
if (!files.includes('token.txt')) writeFileSync('./token.txt', 'STREAM ELEMENTS JWT TOKEN\n')
const jwt = readFileSync('./token.txt', { encoding: 'utf8' })
const io = require('socket.io-client')

const { WebSocketServer } = require('ws')

const wss = new WebSocketServer({ port: 8080 })
const socket = io('https://realtime.streamelements.com', {
    transports: ['websocket'],
})

console.log('Ctrl + C to close')

// Socket connected
socket.on('connect', () => {
    console.log('Successfully connected to StreamElements')
    socket.emit('authenticate', { method: 'jwt', token: jwt })
})
// Socket got disconnected
socket.on('disconnect', () => {
    console.log('Disconnected from StreamElements')
})
// Socket is authenticated
socket.on('authenticated', data => {
    const { channelId } = data
    console.log(`Successfully connected to channel ${channelId}`)
})

socket.on('unauthorized', err => {
    console.log(err)

    setTimeout(() => {
        process.exit(1)
    }, 20_000)
})
socket.on('event:test', data => {
    console.log(data)
})

wss.on('connection', ws => {
    ws.on('error', console.error)

    socket.on('event', data => {
        console.log('event')
        console.log(data)
        console.log('-'.repeat(20))

        if (data.type === 'tip') {
            ws.send(JSON.stringify(data))
        }
    })

    socket.on('event:update', data => {
        // console.log('event:update')
        // console.log(data)
        // console.log('-'.repeat(20))
    })

    ws.on('close', () => {
        console.log('closing connection...')
        socket.off('error')
        socket.off('message')
        socket.off('event')
        socket.off('event:update')
    })
})

