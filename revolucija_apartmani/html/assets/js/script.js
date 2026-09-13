$(".navigacija").on("click",".apartman",function(){
	$(".navigacija .apartman.act").removeClass("act")
	$(this).addClass("act")
	$(".flexBox.druga img").attr("src","")

	apartmanID = $(this).attr("data-id")
	apartmanSlika = $(this).attr("data-slika")
	$(".flexBox.druga img").attr("src",apartmanSlika)
	//$(".flexBox.druga button").attr("data-id",apartmanID)
	$(".flexBox.druga button").attr("onclick",`izabranApartman('${apartmanID}')`)
})



function prikaziApartmane(status,data){
	if (status){
		$("body").fadeIn(300)
		data.forEach(function(apartman){
			$(".box .navigacija").append(`<div class="apartman" data-slika="${apartman.slika}" data-id="${apartman.ime}">${apartman.ime}</div>`)
		})
		$(".box .navigacija .apartman").eq(0).click()
	}
	else{
		$("body").fadeOut(300)
	}
}
window.addEventListener("message", (Event) =>
{
	if(!Event || !Event.data) return;
	//
	return prikaziApartmane(true, Event.data.Apartmani);
});

const ImeResourcea = "revolucija_apartmani";

function izabranApartman(id){
	if(!id) return;
	//
	prikaziApartmane(false);
	//
	return $.post("https://" + ImeResourcea + "/Odabir", JSON.stringify(id));
}

// Dodavanje listener-a za ESC tipku
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        // Sakrij UI i ugasi fokus
        document.body.style.display = 'none';
        
        // Obavesti Lua (FiveM NUI callback) da zatvori fokus
        fetch('https://' + GetParentResourceName() + '/Odabir', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        }).catch(err => {});
    }
});