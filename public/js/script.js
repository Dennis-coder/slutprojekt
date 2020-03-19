function toggleMenu() {
	document.querySelector("nav").classList.toggle("show");
}

function sendMessage(reciever) {
	text = document.querySelector('.text').value;
	document.querySelector('.text').value = ``;
	getId(reciever).then(recieverId => {
		sendMessageToDB(recieverId, text);
	})
	getTimestamp().then(time => {
		time = time.split(" ");
		messagesDiv = document.querySelector('.messages');
		messagesDiv.innerHTML = `<div class='messageDiv centeredColumn space'><div class='message rightMessage'><p>${text}</p></div><span class="timestamp">${time[1].slice(0, 5)}, ${time[0]}</span></div>` + messagesDiv.innerHTML;
	})
}

function messageCheck(id, friendId, latest) {
	setInterval(showMessages(id, friendId, latest), 500);
}

async function showMessages(id, friendId, latest) {
	console.log("hej");
	// getNewMessages(friendId, latest).then(messages => {
	// 	messages.forEach(message => {
	// 	})
	// })
}	

async function getNewMessages(id, latest) {
	const response = await fetch(`http://localhost:9292/api/v1/messages/${id}/${latest}`);
	return await response.json();
}	

async function getId(username) {
	const response = await fetch(`http://localhost:9292/api/v1/get/id/${username}`);
	return response.json();
}	

async function sendMessageToDB(reciever, text) {
	await fetch(`http://localhost:9292/api/v1/message/send/${text}/${reciever}`);
}

async function getTimestamp(){
	const response = await fetch(`http://localhost:9292/api/v1/get/timestamp`);
	return response.json();
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

async function addToChat(id) {
	await fetch(`http://localhost:9292/api/v1/newChat/add/${id}`);
	location.reload();
}

async function removeFromChat(id) {
	await fetch(`http://localhost:9292/api/v1/newChat/remove/${id}`);
	location.reload();
}