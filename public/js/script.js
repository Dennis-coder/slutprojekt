// Toggles the menu.
function toggleMenu() {
	document.querySelector("nav").classList.toggle("show");
}

// Shows your friends.
function viewFriends() {
	if (document.querySelector('.active').innerHTML == `Groups`){
		document.querySelector('.view-friends').classList.toggle("active");
		document.querySelector('.view-groups').classList.toggle("active");
		document.querySelector('.friends').classList.toggle("hidden");
		document.querySelector('.groups').classList.toggle("hidden");
	}
}

// Shows your groups.
function viewGroups() {
	if (document.querySelector('.active').innerHTML == `Friends`){
		document.querySelector('.view-friends').classList.toggle("active");
		document.querySelector('.view-groups').classList.toggle("active");
		document.querySelector('.friends').classList.toggle("hidden");
		document.querySelector('.groups').classList.toggle("hidden");
	}
}

// Sends a message and displays it.
// 
// text - The message text.
// reciever - The id of the person or group to recieve the text.
// type - The type of message, to a friend or to a group.
// time - The current time.
// messagesDiv - The div with all the messages.
function sendMessage(reciever, type) {
	text = document.querySelector('.text').value;
	sendMessageToDB(reciever, text, type);
	getTimestamp().then(time => {
		time = time.split(" ");
		messagesDiv = document.querySelector('.messages');
		messagesDiv.innerHTML += `<div class='message-div centered-column space'><div class='message right-message'><p>${text}</p></div><span class="timestamp">${time[1].slice(0, 5)}, ${time[0]}</span></div>`;
	})
	document.querySelector('.text').value = ``;
	location.reload()
	scrollToBottom()
}

// Starts a checker to dynamically show any new messages sent.
// 
// id - The id of the group or the friend.
// type - The type of check to be done, for a friend or for a group.
function startChecker(id, type) {
	scrollToBottom()
	setInterval(showMessages, 200, id, type);
}

// Prints the new messages.
// 
// id - The id of the group or the friend.
// type - The type of check to be done, for a friend or for a group.
// latest - The timestamp of last check.
// messages - The new messages.
// message - One of the new messages.
// time - The current time.
// messagesDiv - The div with all the messages.
function showMessages(id, type) {
	latest = document.querySelector('.timestamp-checker').value;
	getNewMessages(id, latest, type).then(messages => {
		for (i in messages){
			message = messages[i]
			time = message['timestamp'].split(" ");
			messagesDiv = document.querySelector('.messages');
			if (type == `group`){
				messagesDiv.innerHTML += `<p>${message['sender']}</p>`
			}
			messagesDiv.innerHTML += `<div class='message-div centered-column'><div class='message left-message'><p>${message['text']}</p></div><span class="timestamp">${time[1].slice(0, 5)}, ${time[0]}</span></div>`;
			document.querySelector('.timestamp-checker').value = message['timestamp'];
			scrollToBottom()
		}
	})
}

// Scrolls to the bottom of the messages.
// 
// element - The element of which we want to scroll to the bottom.
function scrollToBottom(){
    var element = document.querySelector(".messages");
    element.scrollTop = element.scrollHeight;
}

// Shows the form to change password.
function togglePasswordChange(){
	document.querySelector('.password').classList.toggle("hidden");
}

// Shows the form to send a report.
function toggleUserReport(){
	document.querySelector('.report').classList.toggle("hidden");
}

// Pop up to confirm deletion of your account.
// 
// id - Your user id.
function deleteConfirm(id){
	if (confirm(`Press OK if you wish to proceed and delete your account`) == true){
		deleteUser(id);
	}
}

// Shows reports.
function toggleReports(){
	document.querySelector('.reports').classList.toggle("hidden");
}

// Pop up to delete and confirm deletion of an account.
// 
// name - The account to be deleted.
// id - The user id of the account to be deleted.
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

// Gets new messages.
// 
// id - The id of the friend or group we want to get messages for.
// latest - The timestamp of last check.
// type - If it is to a group or friend
// 
// Returns the new messages.
async function getNewMessages(id, latest, type) {
	const response = await fetch(`http://localhost:9292/api/get/${type}/messages/${id}/${latest}`);
	return await response.json();
}	

// Gets the id of a user from the username.
// 
// username - The username of the user whos id you want.
// id - The user id to be returned.
// 
// Examples
// 
// 	getId('Deleted user')
//	# => 0
// 
// 	getId('Tester1')
//	# => 1
// 
// Returns the user id.
async function getId(username) {
	const id = await fetch(`http://localhost:9292/api/get/id/${username}`);
	return id.json();
}	

// Sends a message to the database.
// 
// reciever - The id of the user or group to recieve the message.
// text - The message text.
// type - If it is to a group or friend
async function sendMessageToDB(reciever, text, type) {
	await fetch(`http://localhost:9292/api/message/send/${type}/${text}/${reciever}`)
}

// Gets the current time.
// 
// response - The current time.
// 
// Returns the current time.
async function getTimestamp(){
	const response = await fetch(`http://localhost:9292/api/get/timestamp`);
	return response.json();
}

// andle a friend request.
// 
// id - Your user id.
// action - The action to perform.
async function request(id, action) {
	await fetch(`http://localhost:9292/api/requests/${id}/${action}`);
	location.reload();
}

// Delete an account.
// 
// id - The user id.
async function deleteUser(id){
	await fetch(`http://localhost:9292/api/admin/delete_user/${id}`);
	location.reload()
}

// Remove a report.
// 
// reportId - The report id.
async function removeReport(reportId){
	await fetch(`http://localhost:9292/api/admin/remove_report/${reportId}`)
	location.reload()
}
