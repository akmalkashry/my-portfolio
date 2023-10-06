let cloudleft2 = document.getElementById("cloudleft2");
let cloudright2 = document.getElementById("cloudright2");
let cloudmiddle2 = document.getElementById("cloudmiddle2");
let bgvideo2 = document.getElementById("bgvideo2");
window.addEventListener('scroll', ()=>{
    let value = window.scrollY;

    cloudleft2.style.marginLeft = value * -2.5 + 'px';
    cloudright2.style.marginRight = value * -2.5 + 'px';
    cloudmiddle2.style.marginBottom = value * 1.5 + 'px';
    
})


window.addEventListener("load", function(){
    setTimeout(
        function open(event){
            document.querySelector(".popup").style.display = "block";
        },
        1000
    )
});

document.querySelector("#closes").addEventListener("click", function(){
    document.querySelector(".popup").style.display = "none";
});