function toggleMenu() {
	document.querySelector("nav").classList.toggle("show");
}

function sendMessage(userId, reciever) {
	text = document.querySelector('.text').value;
	sendMessageAPI(userId, reciever, text);
	messagesDiv = document.querySelector('.messages');
}

function messageCheck(id, friend){
	getId(friend).then((friendId) => {
		getLatest(id, friendId).then((latest) => {
			setInterval(showMessages(frienId, latest), 200);
		})
	})
}	

function showMessages(id, latest) {
	getNewMessages(id, latest).then((messages) => {
		messages.forEach(message => {
			messagesDiv = document.querySelector('.messages');
			console.log(message);
		})
	})
}	


async function getNewMessages(id, latest) {
	const response = await fetch(`http://localhost:9292/api/v1/messages/${id}/${latest}`);
	return await response.json();
}	

async function getId(username) {
	const response = await fetch(`http://localhost:9292/api/v1/get/id/${username}`);
	return await response.json();
}	

async function sendMessageToDB(sender, reciever, text) {
	await fetch(`http://localhost:9292/api/v1/send_message/${text}/${sender}/${reciever}`);
}

async function request(id, action) {
	if (action == `Send`){
		await fetch(`http://localhost:9292/api/v1/requests/${id}/send`);
	} else if (action ==`Accept`) {
		await fetch(`http://localhost:9292/api/v1/requests/${id}/accept`);
	} else {
		await fetch(`http://localhost:9292/api/v1/requests/${id}/delete`);
	}
	location.reload();
}

async function addToChat(id, list) {
}

async function addToChat(id, list) {
}