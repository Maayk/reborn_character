var selectedChar = null;
var vipstatus = ""
RebornCharacter = {}
// $('.container').fadeOut();

$(document).ready(function (){
    window.addEventListener('message', function (event) {
        var item = event.data;

        if (item.loading == true){
            $('.reborn-loading').fadeIn(500);
            setTimeout(function(){
                $('.reborn-loading').fadeOut(500);
                // console.log('fechou o carregamento')
                setTimeout(function(){
                    $('.container').fadeIn(250);
                    $('.characters-list').fadeIn(250);
                    console.log('carregou personagens')
                    $.post('https://reborn_character/setupCharacters');
                }, 400)
            }, 6000)
        };

        if (item.action == "openUI") {
            // $('.reborn-loading').fadeOut(500);
            if (item.toggle == true) {
                RebornCharacter.resetAll();
                setTimeout(function(){
                    $('.container').fadeIn(250);
                    $('.characters-list').fadeIn(550);
                    $.post('https://reborn_character/setupCharacters');
                }, 400)
            } else {
                $('.container').fadeOut(250);
                $('.characters-list').fadeOut(550);
                RebornCharacter.resetAll();
            }   
        }

        if (item.action == "setupCharacters") {
            setupCharacters(event.data.characters)
        }

        if (item.action == "setupCharInfo") {
            setupCharInfo(event.data.chardata)
        }
        if (item.action == "atualizavip") {
            vipstatus = event.data.vipstatus
        }
    });

    $('.datepicker').datepicker();
});

var formatter = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
});

function setupCharInfo(cData) {
    if (cData == 'empty') {
        $('.character-info-valid').html('<span id="no-char">The selected character slot is not yet in use.<br><br>This character has no information yet.</span>');
    } else {
        var gender = "Man"
        if (cData.charinfo.gender == 1) { gender = "Woman" }
        $('.character-info-valid').html(
        '<div class="character-info-box"><span id="info-label">Name: </span><span class="char-info-js">'+cData.charinfo.firstname+' '+cData.charinfo.lastname+'</span></div>' +
        '<div class="character-info-box"><span id="info-label">Date of Birth: </span><span class="char-info-js">'+cData.charinfo.birthdate+'</span></div>' +
        '<div class="character-info-box"><span id="info-label">Gender: </span><span class="char-info-js">'+gender+'</span></div>' +
        '<div class="character-info-box"><span id="info-label">Nationality: </span><span class="char-info-js">'+cData.charinfo.nationality+'</span></div>' +
        '<div class="character-info-box"><span id="info-label">Job: </span><span class="char-info-js">'+cData.job.label+'</span></div>' +
        '<div class="character-info-box"><span id="info-label">Cash: </span><span class="char-info-js">&#36; '+cData.money.cash+'</span></div>' +
        '<div class="character-info-box"><span id="info-label">Bank: </span><span class="char-info-js">&#36; '+cData.money.bank+'</span></div><br>' +
        '<div class="character-info-box"><span id="info-label">Phone Number: </span><span class="char-info-js">'+cData.charinfo.phone+'</span></div>' +
        '<div class="character-info-box"><span id="info-label">Account #: </span><span class="char-info-js">'+cData.charinfo.account+'</span></div>');
    }
}

function setupCharacters(characters) {
    $.each(characters, function(index, char){
        $('#char-'+char.cid).html("");
        $('#char-'+char.cid).data("citizenid", char.citizenid);
        var fotoperfil = `https://i.ibb.co/PF4QcQy/character-pic.png`
        if (char.metadata.phone['profilepicture'] !== undefined){
            fotoperfil = char.metadata.phone['profilepicture']
        } else {
            fotoperfil = `https://i.ibb.co/PF4QcQy/character-pic.png`
        }

        setTimeout(function(){
            $('#char-'+char.cid).html('<div class="character-header"></div><div class="user-info-block"><div class="creation-date"><a></a></div><div class="user-avatar"><img src="'+fotoperfil+'" alt=""></div><div class="tipo-conta"><a></a></div><p class="nome-do-personagem">'+char.charinfo.firstname+' '+char.charinfo.lastname+'</p></div>   <div class="personagem-block"><a>Identidade</a><div class="personagem-info"><a>' + char.citizenid + '</a></div><a>Aniversário</a><div class="personagem-info"><a>'+char.charinfo.birthdate+'</a></div><a>Celular</a><div class="personagem-info"><a>'+char.charinfo.phone+'</a></div><a>Dinheiro em Mãos</a><div class="personagem-info"><a>'+formatter.format(char.money.cash)+'</a></div><a>Dinheiro no Banco</a><div class="personagem-info"><a>'+formatter.format(char.money.bank)+'</a></div><a>Trabalho Atual</a><div class="personagem-info"><a>'+char.job.label+'</a></div></div> <div class="selecionar-char charsec-'+char.cid+'" id="selecionar"><p id="select-text">Selecionar Personagem</p></div>'
            
            );
        
            $('#char-'+char.cid).data('cData', char)
            $('#char-'+char.cid).data('cid', char.cid)
            $('.charsec-'+char.cid).data('cData', char)
        }, 100)
    })
}

$(document).on('click', '#selecionar', function(e) {
    e.preventDefault();
    // console.log()
    var CharSelecionado = $(this).data('cData')
    if(CharSelecionado !== null){
        $.post('https://reborn_character/selectCharacter', JSON.stringify({
                cData: $(this).data('cData')
        }));
        RebornCharacter.fadeInDown('.welcomescreen', '15%', 400);
        RebornCharacter.fadeInDown('.server-log', '25%', 400);
        setTimeout(function(){
            RebornCharacter.fadeOutDown('.characters-list', "-40%", 400);
            RebornCharacter.fadeOutDown('.character-info', "-40%", 400);
        }, 300);
        RebornCharacter.resetAll();
    } else {
        $('.characters-list').css("filter", "blur(2px)")
        $('.characters-list').css("opacity", "0.6")
      
        $('.character-register').fadeIn(400);
        $('.character-btn').fadeOut(250);
        $('.character-register').css("display", "flex")
    }
});

$(document).on('click', '#play', function(e) {
    e.preventDefault();
    var charData = $(selectedChar).data('cid');
    // console.log(charData)
    if (selectedChar !== null) {
        if (charData !== "") {
            $('#play').fadeOut(250)
        } else {
            $('.characters-list').css("filter", "blur(2px)")
            $('.characters-list').css("opacity", "0.6")
          
            $('.character-register').fadeIn(400);
            $('.character-btn').fadeOut(250);
            $('.character-register').css("display", "flex")
        }
    }
});


$(document).on('click', '.character', function(e) {
    var cDataPed = $(this).data('cData');
    e.preventDefault();
    if (selectedChar === null) {
        selectedChar = $(this);
        if ((selectedChar).data('cid') == "") {
            $(selectedChar).addClass("char-selected");
            setupCharInfo('empty')
            $("#play-text").html("+");
            $("#play").fadeIn('fast');
            //$("#delete").css({"display":"none"});
            $.post('https://reborn_character/cDataPed', JSON.stringify({
                cData: cDataPed
            }));
        }else{
            $("#play").fadeOut('fast');
        }
    } else {
        $(selectedChar).removeClass("char-selected");
        selectedChar = $(this);
        if ((selectedChar).data('cid') == "") {
            $(selectedChar).addClass("char-selected");
            setupCharInfo('empty')
            $("#play-text").html("+");
            $("#play").fadeIn('fast');
            //$("#delete").css({"display":"none"});
            $.post('https://reborn_character/cDataPed', JSON.stringify({
                cData: cDataPed
            }));
        }else{
            $("#play").fadeOut('fast');
        }
    }
});

$(document).on('click', '#create', function (e) {
    var idpersonagem = $(selectedChar).attr('id').replace('char-', '')
    e.preventDefault();
    // console.log(vipstatus)
    if (idpersonagem > 1) {
        if (vipstatus == "platina") {
            $(".container").fadeOut(150);
            $('.characters-list').css("filter", "none");
            $('.character-info').css("filter", "none");
            $('.characters-list').css("opacity", "1")
            $('.character-register').fadeOut(250);
        
            $('.reborn-loading').fadeIn(500);
        
            setTimeout(function(){
                $('.reborn-loading').fadeOut(500);
            }, 2500)
        
            $.post('https://reborn_character/createNewCharacter', JSON.stringify({
                firstname: $('#first_name').val(),
                lastname: $('#last_name').val(),
                nationality: $('#nationality').val(),
                birthdate: $('#birthdate').val(),
                gender: $('select[name=gender]').val(),
                cid: $(selectedChar).attr('id').replace('char-', ''),
            }));
        
            refreshCharacters()
        } else {
            $('.character-register').fadeOut(250)
            $('.container').fadeIn(250);
            $('.characters-list').fadeIn(550);
            $('.character-btn').fadeIn(250);
            $('.characters-list').css("filter", "none")
            $('.characters-list').css("opacity", "1")
            // refreshCharacters()
        }
    } else {
        $(".container").fadeOut(150);
        $('.characters-list').css("filter", "none");
        $('.character-info').css("filter", "none");
        $('.characters-list').css("opacity", "1")
        $('.character-register').fadeOut(250);
    
        $('.reborn-loading').fadeIn(500);
    
        setTimeout(function(){
            $('.reborn-loading').fadeOut(500);
        }, 2500)
    
        $.post('https://reborn_character/createNewCharacter', JSON.stringify({
            firstname: $('#first_name').val(),
            lastname: $('#last_name').val(),
            nationality: $('#nationality').val(),
            birthdate: $('#birthdate').val(),
            gender: $('select[name=gender]').val(),
            cid: $(selectedChar).attr('id').replace('char-', ''),
        }));
    
        refreshCharacters()
    }
  
});

$(document).on('click', '#cancelar', function(e){
    e.preventDefault();
    $('.characters-list').css("filter", "none");
    $('.character-info').css("filter", "none");
    $('.character-register').fadeOut(250);
    $('.characters-list').css("opacity", "1")
    $('.character-btn').fadeIn(250);
});

function refreshCharacters() {
    $('.characters-list').html('<div class="character" id="char-1" data-cid=""><div class="character-header-off"></div><div class="info-characters"><p class="information-new">Ao criar um novo personagem você concorda que ele não terá relação alguma com seu outro personagem<br />E concorda que se algo for encontrado pela administração a punição será aplicada diretamente na conta<br />Resumindo, a punição será aplicada na conta dependendo da gravidade da situação<br />Não abuse da mecânica, Bom Roleplay!</p><h2 class="slot-number-style">SLOT 1</h2><div class="icon-newcharacter"></div></div></div><div class="character" id="char-2" data-cid=""><div class="character-header-off"></div><div class="info-characters"><p class="information-new">Ao criar um novo personagem você concorda que ele não terá relação alguma com seu outro personagem<br />E concorda que se algo for encontrado pela administração a punição será aplicada diretamente na conta<br />Resumindo, a punição será aplicada na conta dependendo da gravidade da situação<br />Não abuse da mecânica, Bom Roleplay!</p><h2 class="slot-number-style">SLOT 2</h2><div class="icon-newcharacter"></div></div></div><div class="character" id="char-3" data-cid=""><div class="character-header-off"></div><div class="info-characters"><p class="information-new">Ao criar um novo personagem você concorda que ele não terá relação alguma com seu outro personagem<br />E concorda que se algo for encontrado pela administração a punição será aplicada diretamente na conta<br />Resumindo, a punição será aplicada na conta dependendo da gravidade da situação<br />Não abuse da mecânica, Bom Roleplay!</p><h2 class="slot-number-style">SLOT 3</h2><div class="icon-newcharacter"></div></div></div>')
    setTimeout(function(){
        $(selectedChar).removeClass("char-selected");
        selectedChar = null;
        $.post('https://reborn_character/setupCharacters');
        //$("#delete").css({"display":"none"});
        $("#play").css({"display":"none"});
        RebornCharacter.resetAll();
    }, 100)
}

RebornCharacter.fadeOutUp = function(element, time) {
    $(element).css({"display":"block"}).animate({top: "-80.5%",}, time, function(){
        $(element).css({"display":"none"});
    });
}

RebornCharacter.fadeOutDown = function(element, percent, time) {
    if (percent !== undefined) {
        $(element).css({"display":"block"}).animate({top: percent,}, time, function(){
            $(element).css({"display":"none"});
        });
    } else {
        $(element).css({"display":"block"}).animate({top: "103.5%",}, time, function(){
            $(element).css({"display":"none"});
        });
    }
}

RebornCharacter.fadeInDown = function(element, percent, time) {
    $(element).css({"display":"-webkit-box"}).animate({top: percent,}, time);
}

RebornCharacter.resetAll = function() {
    $('.characters-list').hide();
    $('.characters-list').css("top", "-40");
    $('.character-info').hide();
    $('.character-info').css("top", "-40");
    $('.welcomescreen').show();
    $('.welcomescreen').css("top", "15%");
    $('.server-log').show();
    $('.server-log').css("top", "25%");
}