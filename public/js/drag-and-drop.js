const items = document.querySelectorAll('.draggable');
const taskGroups = document.querySelectorAll('.task-group')

items.forEach(function(item) {
    item.addEventListener('drag', handleDrag, false);
    item.addEventListener('dragstart', handleDragStart, false);
    item.addEventListener('dragend', handleDragEnd, false);
});

taskGroups.forEach(function(group) {
    group.addEventListener('drop', handleDrop)
    group.addEventListener('dragover', handleDrop);
})

function handleDrag() {
	this.classList.add('is-moving');
}

function handleDrop(e) {
    e.preventDefault();
    let data = e.dataTransfer.getData('text');
    let element = document.getElementById(data);

    let posY = e.clientY

    let listItems = this.querySelectorAll('.draggable')
    let nextNode;

    for (let node of listItems) {
        if (posY < node.getBoundingClientRect().y + node.getBoundingClientRect().height / 2)
            break
        nextNode = node
    }

    if (nextNode)
        nextNode.insertAdjacentElement('afterend', element);
    else 
        this.querySelector('.d-grid').insertAdjacentElement('afterbegin', element);
}

function handleDragStart(e) {
    e.dataTransfer.effectAllowed = 'move';
    e.dataTransfer.setData('text', this.id);
}

function handleDragEnd(e) {
    this.classList.remove('is-moving');
	
	window.setTimeout(function() {
		e.target.classList.add('is-moved');
		window.setTimeout(function() {
			e.target.classList.remove('is-moved');
		}, 1000);
	}, 100);
}

