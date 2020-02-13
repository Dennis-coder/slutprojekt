async function timer(id, latest){
	setTimeout(showMessages(id, latest), 500);
}

function showMessages(id, latest) {
	messagesDiv = document.querySelector('.messages')
	getNewMessages(id, latest).then((messages) => {
		messages.forEach(message => {
			getUserId().then((userId) => {
				getSenderUsername(message[0]).then((sender) => {
					console.log(sender);
					console.log(userId);
					messageDiv = `<div class="message">`;
					if (message[3] == userId){
						messageDiv += `<p>Me:</p>`;
					}
					else{
						messageDiv += `<p>${sender}</p>`;
					}
					messageDiv +=  `<p>${message[1]}</p>`;
					messageDiv +=  `<p>Sent at ${message[2]}</p></div>`;
					messagesDiv.innerHTML = messageDiv + messagesDiv.innerHTML;
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

async function getUserId() {
	const response = await fetch(`http://localhost:9292/api/v1/get/user_id`);
	return await response.json();
}

async function getSenderUsername(id) {
	const response = await fetch(`http://localhost:9292/api/v1/message/${id}/sender`);
	return await response.json();
}

function toggleMenu() {
    document.querySelector("nav").classList.toggle("show")
}

async function sendRequest(id) {
	await fetch(`http://localhost:9292/api/v1/requests/${id}/send`);
	location.reload()
}

async function acceptRequest(id) {
	await fetch(`http://localhost:9292/api/v1/requests/${id}/accept`);
	location.reload()
}

async function declineRequest(id) {
	await fetch(`http://localhost:9292/api/v1/requests/${id}/delete`);
	location.reload()
}

async function deleteRequest(id) {
	await fetch(`http://localhost:9292/api/v1/requests/${id}/delete`);
	location.reload()
}

async function deleteFriend(id) {
	await fetch(`http://localhost:9292/api/v1/requests/${id}/delete`);
	location.reload()
}

async function addToChat(id, list) {
	await fetch(`http://localhost:9292/api/v1/remove_from_chat/${id}`);
	location.reload();
}

async function addToChat(id, list) {
	await fetch(`http://localhost:9292/api/v1/add_to_chat/${id}`);
	location.reload();
}