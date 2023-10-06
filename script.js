/*PARALLAX MOVEMENT----------------------*/
let logo = document.getElementById("logo");
let cloudleft = document.getElementById("cloudleft");
let cloudright = document.getElementById("cloudright");
let cloudmiddle = document.getElementById("cloudmiddle");
let bgvideo = document.getElementById("bgvideo");

window.addEventListener('scroll', ()=>{
    let value = window.scrollY;

    logo.style.marginTop = value * 1.5 + 'px';
    cloudleft.style.marginLeft = value * -2.5 + 'px';
    cloudright.style.marginRight = value * -2.5 + 'px';
    cloudmiddle.style.marginBottom = value * 1.5 + 'px';

})

/*HOVERING AUDIO-------------------------*/
function playAudio(hover1) {
    var audio = document.getElementById(hover1);
    audio.play();
}
function pauseAudio(hover1) {
    var audio = document.getElementById(hover1);
    audio.pause();
}
function restartAudio(hover1) {
    var audio = document.getElementById(hover1);
    audio.currentTime = 0; // Reset playback to the beginning
}

/*REVEAL LIST 1 BY 1 WHEN SCROLLING---------------------------*/
try {
	Typekit.load({
		async: true
	});
} catch (e) {}

function revealOnScroll() {
    const listItems = document.querySelectorAll('.gmglist li');
    
    listItems.forEach((item) => {
      if (isElementInViewport(item)) {
        item.classList.add('show');
      } else {
        item.classList.remove('show'); // Remove 'show' class when not in view
      }
    });
  }
  
  window.addEventListener('scroll', revealOnScroll);
  
  function isElementInViewport(el) {
    const rect = el.getBoundingClientRect();
    return (
      rect.top >= 0 &&
      rect.left >= 0 &&
      rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
      rect.right <= (window.innerWidth || document.documentElement.clientWidth)
    );
  }
  
  revealOnScroll(); // Initially reveal elements that are in view

  