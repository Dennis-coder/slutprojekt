function toggleMenu() {
	document.querySelector("nav").classList.toggle("show");
}

function viewFriends() {
	if (document.querySelector('.active').innerHTML == `Groups`){
		document.querySelector('.viewFriends').classList.toggle("active");
		document.querySelector('.viewGroups').classList.toggle("active");
		document.querySelector('.friends').classList.toggle("hidden");
		document.querySelector('.groups').classList.toggle("hidden");
	}
}

function viewGroups() {
	if (document.querySelector('.active').innerHTML == `Friends`){
		document.querySelector('.viewFriends').classList.toggle("active");
		document.querySelector('.viewGroups').classList.toggle("active");
		document.querySelector('.friends').classList.toggle("hidden");
		document.querySelector('.groups').classList.toggle("hidden");
	}
}

function sendMessage(reciever) {
	text = document.querySelector('.text').value;
	sendMessageToDB(reciever, text);
	getTimestamp().then(time => {
		time = time.split(" ");
		messagesDiv = document.querySelector('.messages');
		messagesDiv.innerHTML = `<div class='messageDiv centeredColumn space'><div class='message rightMessage'><p>${text}</p></div><span class="timestamp">${time[1].slice(0, 5)}, ${time[0]}</span></div>` + messagesDiv.innerHTML;
	})
	document.querySelector('.text').value = ``;
}

function sendGroupMessage(reciever) {
	text = document.querySelector('.text').value;
	sendGroupMessageToDB(reciever, text);
	getTimestamp().then(time => {
		time = time.split(" ");
		messagesDiv = document.querySelector('.messages');
		messagesDiv.innerHTML = `<div class='messageDiv centeredColumn space'><div class='message rightMessage'><p>${text}</p></div><span class="timestamp">${time[1].slice(0, 5)}, ${time[0]}</span></div>` + messagesDiv.innerHTML;
	})
	document.querySelector('.text').value = ``;
}

function startChecker(id, friendId) {
	setInterval(showMessages, 200, id, friendId);
}

function showMessages(id, friendId) {
	latest = document.querySelector('.timestampChecker').value;
	console.log(latest)
	getNewMessages(friendId, latest).then(messages => {
		for (i in messages){
			message = messages[i]
			time = message['timestamp'].split(" ");
			messagesDiv = document.querySelector('.messages');
			messagesDiv.innerHTML = `<div class='messageDiv centeredColumn space'><div class='message leftMessage'><p>${message['text']}</p></div><span class="timestamp">${time[1].slice(0, 5)}, ${time[0]}</span></div>` + messagesDiv.innerHTML;
			document.querySelector('.timestampChecker').value = message['timestamp'];
		}
	})
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
	await fetch(`http://localhost:9292/api/v1/message/send/${text}/${reciever}`)
}

async function sendGroupMessageToDB(reciever, text) {
	await fetch(`http://localhost:9292/api/v1/group_message/send/${text}/${reciever}`)
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
