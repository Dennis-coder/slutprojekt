function toggleMenu() {
	document.querySelector("nav").classList.toggle("show");
}

function sendMessage(userId, reciever) {
	text = document.querySelector('.text').value;
	sendMessageAPI(userId, reciever, text);
	messagesDiv = document.querySelector('.messages');
}

function messageCheck(id, reciever){
	getId(reciever).then((reciever) => {
		getLatest(id, reciever).then((latest) => {
			
		})
	})
	// setInterval(showMessages(id, latest), 500);
}	

function showMessages(id, latest) {
	messagesDiv = document.querySelector('.messages');
	getNewMessages(id, latest).then((messages) => {
		messages.forEach(message => {
			getUserId().then((userId) => {
				getSenderUsername(message[0]).then((sender) => {
					newDiv = `<div class="message">`;
					if (message[3] == userId){
						newDiv += `<p>Me:</p>`;
					}	
					else{
						newDiv += `<p>${sender}</p>`;
					}	
					newDiv +=  `<p>${message[1]}</p>`;
					newDiv +=  `<p>Sent at ${message[2]}</p></div>`;
					messagesDiv.innerHTML = newDiv + messagesDiv.innerHTML;
				})	
			})	
		});	
	}	
	)
}	


async function getNewMessages(id, latest) {
	const response = await fetch(`http://localhost:9292/api/v1/users/${id}/messages/${latest}`);
	return await response.json();
}	

async function getId(username) {
	const response = await fetch(`http://localhost:9292/api/v1/get/id/${username}`);
	return await response.json();
}	

async function getSender(id) {
	const response = await fetch(`http://localhost:9292/api/v1/message/${id}/sender`);
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