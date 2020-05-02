function toggleMenu() {
	document.querySelector("nav").classList.toggle("show");
}

function viewFriends() {
	if (document.querySelector('.active').innerHTML == `Groups`){
		document.querySelector('.view-friends').classList.toggle("active");
		document.querySelector('.view-groups').classList.toggle("active");
		document.querySelector('.friends').classList.toggle("hidden");
		document.querySelector('.groups').classList.toggle("hidden");
	}
}

function viewGroups() {
	if (document.querySelector('.active').innerHTML == `Friends`){
		document.querySelector('.view-friends').classList.toggle("active");
		document.querySelector('.view-groups').classList.toggle("active");
		document.querySelector('.friends').classList.toggle("hidden");
		document.querySelector('.groups').classList.toggle("hidden");
	}
}

function sendMessage(reciever) {
	text = document.querySelector('.text').value;
	sendMessageToDB(reciever, text, `friend`);
	getTimestamp().then(time => {
		time = time.split(" ");
		messagesDiv = document.querySelector('.messages');
		messagesDiv.innerHTML += `<div class='message-div centered-column space'><div class='message right-message'><p>${text}</p></div><span class="timestamp">${time[1].slice(0, 5)}, ${time[0]}</span></div>`;
	})
	document.querySelector('.text').value = ``;
	scrollToBottom()
}

function sendGroupMessage(reciever) {
	text = document.querySelector('.text').value;
	sendMessageToDB(reciever, text, `group`);
	getTimestamp().then(time => {
		time = time.split(" ");
		messagesDiv = document.querySelector('.messages');
		messagesDiv.innerHTML += `<div class='message-div centered-column space'><div class='message right-message'><p>${text}</p></div><span class="timestamp">${time[1].slice(0, 5)}, ${time[0]}</span></div>`;
	})
	document.querySelector('.text').value = ``;
	scrollToBottom()
}

function startChecker(friendId) {
	scrollToBottom()
	setInterval(showMessages, 200, friendId);
}

function showMessages(friendId) {
	latest = document.querySelector('.timestamp-checker').value;
	getNewMessages(friendId, latest).then(messages => {
		for (i in messages){
			message = messages[i]
			time = message['timestamp'].split(" ");
			messagesDiv = document.querySelector('.messages');
			messagesDiv.innerHTML += `<div class='message-div centered-column space'><div class='message left-message'><p>${message['text']}</p></div><span class="timestamp">${time[1].slice(0, 5)}, ${time[0]}</span></div>`;
			document.querySelector('.timestamp-checker').value = message['timestamp'];
			scrollToBottom()
		}
	})
}	

function startGroupChecker(groupId) {
	scrollToBottom()
	setInterval(showGroupMessages, 200, groupId);
}

function showGroupMessages(groupId) {
	latest = document.querySelector('.timestamp-checker').value;
	getNewGroupMessages(groupId, latest).then(messages => {
		for (i in messages){
			message = messages[i]
			time = message['timestamp'].split(" ");
			messagesDiv = document.querySelector('.messages');
			messagesDiv.innerHTML += `<p>${message['sender']}</p><div class='message-div centered-column'><div class='message left-message'><p>${message['text']}</p></div><span class="timestamp">${time[1].slice(0, 5)}, ${time[0]}</span></div>`;
			document.querySelector('.timestamp-checker').value = message['timestamp'];
			scrollToBottom()
		}
	})
}

function scrollToBottom(){
    var element = document.querySelector(".messages");
    element.scrollTop = element.scrollHeight;
}

function togglePasswordChange(){
	document.querySelector('.password').classList.toggle("hidden");
}

function toggleUserReport(){
	document.querySelector('.report').classList.toggle("hidden");
}

function deleteConfirm(id){
	if (confirm(`Press OK if you wish to proceed and delete your account`) == true){
		deleteUser(id);
	}
}

function toggleReports(){
	document.querySelector('.reports').classList.toggle("hidden");
}

function adminDeleteUser(){
	var name = prompt("Please enter their name:");
	if (name != null){
		if (confirm(`Press OK if you wish to proceed and delete ${name}'s account`) == true){
			getId(name).then(id => {
				deleteUser(id);
			})
		}
	}
}

async function getNewMessages(id, latest) {
	const response = await fetch(`http://localhost:9292/api/messages/${id}/${latest}`);
	return await response.json();
}	

async function getNewGroupMessages(id, latest) {
	const response = await fetch(`http://localhost:9292/api/group_messages/${id}/${latest}`);
	return await response.json();
}

async function getId(username) {
	const response = await fetch(`http://localhost:9292/api/get/id/${username}`);
	return response.json();
}	

async function sendMessageToDB(reciever, text, type) {
	await fetch(`http://localhost:9292/api/message/send/${type}/${text}/${reciever}`)
}

async function getTimestamp(){
	const response = await fetch(`http://localhost:9292/api/get/timestamp`);
	return response.json();
}

async function request(id, action) {
	if (action == `Send`){
		await fetch(`http://localhost:9292/api/requests/${id}/send`);
	} else if (action ==`Accept`) {
		await fetch(`http://localhost:9292/api/requests/${id}/accept`);
	} else {
		await fetch(`http://localhost:9292/api/requests/${id}/delete`);
	}
	location.reload();
}

async function deleteUser(id){
	await fetch(`http://localhost:9292/api/admin/delete_user/${id}`);
	location.reload()
}
async function removeReport(report_id){
	await fetch(`http://localhost:9292/api/admin/remove_report/${report_id}`)
	location.reload()
}
