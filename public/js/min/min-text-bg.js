const elements=document.querySelectorAll(".text-bg-check");function checkColor(e){let c=e.style["background-color"],l=(c=c.replace(/[^\d,]/g,"").split(","))[0],o=c[1],t=c[2];e.style.color=.299*l+.587*o+.114*t>186?"#000000":"#FFFFFF"}elements.forEach(e=>checkColor(e));