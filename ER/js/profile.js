const editUsernameButton = document.getElementById('button-editUsername')
const editNameButton = document.getElementById('button-editName')
const editEmailButton = document.getElementById('button-editEmail')
const editCompanyButton = document.getElementById('button-editCompany')

if (editUsernameButton) {
	editUsernameButton.addEventListener('click', function() {
		const usernameInput = document.getElementById('usernameInput')
		
		if (usernameInput.disabled) {
			editUsernameButton.innerHTML = '<i class="bi bi-check2"></i>'
			usernameInput.disabled = false
		} else {
			editUsernameButton.innerHTML = '<i class="bi bi-pencil"></i>'
			usernameInput.disabled = true
		}
	})
}

if (editNameButton) {
	editNameButton.addEventListener('click', function() {
		const nameInput = document.getElementById('nameInput')
		
		if (nameInput.disabled) {
			editNameButton.innerHTML = '<i class="bi bi-check2"></i>'
			nameInput.disabled = false
		} else {
			editNameButton.innerHTML = '<i class="bi bi-pencil"></i>'
			nameInput.disabled = true
		}
	})
}

if (editEmailButton) {
	editEmailButton.addEventListener('click', function() {
		const emailInput = document.getElementById('emailInput')
		
		if (emailInput.disabled) {
			editEmailButton.innerHTML = '<i class="bi bi-check2"></i>'
			emailInput.disabled = false
		} else {
			editEmailButton.innerHTML = '<i class="bi bi-pencil"></i>'
			emailInput.disabled = true
		}
	})
}

if (editCompanyButton) {
	editCompanyButton.addEventListener('click', function() {
		const companyInput = document.getElementById('companyInput')
		
		if (companyInput.disabled) {
			editCompanyButton.innerHTML = '<i class="bi bi-check2"></i>'
			companyInput.disabled = false
		} else {
			editCompanyButton.innerHTML = '<i class="bi bi-pencil"></i>'
			companyInput.disabled = true
		}
	})
}
