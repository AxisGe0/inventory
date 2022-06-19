var bar = new ProgressBar.SemiCircle('.progress-bar',{strokeWidth: 4,easing: 'easeInOut',duration: 1400,color: '#eee',trailColor: '#a9a9a9',trailWidth: 1,svgStyle: null});
AXFW = {
    Inventory:{
        MaxSlots:54
    },
}
AXFW.Inventory.CraftingItems = {
    "lockpick":[
        {name:'metalscrap',amount:22,image:'metalscrap.png',label:'MetalScrap'},
        {name:'plastic',amount:20,image:'plastic.png',label:'Plastic'}
    ],
    'screwdriverset':[
        {name:'metalscrap',amount:30,image:'metalscrap.png',label:'MetalScrap'},
        {name:'plastic',amount:40,image:'plastic.png',label:'Plastic'}
    ],
    'advancedlockpick':[
        {name:'screwdriverset',amount:1,image:'screwdriverset.png',label:'Toolkit'},
        {name:'lockpick',amount:1,image:'lockpick.png',label:'Lockpick'}
    ],
    'ironoxide':[
        {name:'iron',amount:70,image:'iron.png',label:'Iron'},
        {name:'glass',amount:70,image:'glass.png',label:'Glass'}
    ],
    'aluminumoxide':[
        {name:'aluminum',amount:70,image:'aluminum.png',label:'Aluminium'},
        {name:'glass',amount:70,image:'glass.png',label:'Glass'}
    ]
}
AXFW.Inventory.Open = function(items,refresh,other,plyweight){
    if(!refresh){$('.inventory').fadeIn();AddLog('Opening Player Inventory '+(other != undefined && 'and '+other.id || ''))}
    $('.settings-tab').hide()
    $('.player-quick').find('.item-box').remove()
    $('.player-pocket').find('.item-box').remove()
    $('.player-inventory').find('.item-box').remove()
    $('.other-inventory').find('.item-box').remove()
    for(i=1;i<6+1;i++){///QuickItems
        $('.player-quick .player-quick-items').append(`<div data-slot="${i}" class="item-box"></div>`)
    }
    for(i=7;i<12+1;i++){///Pocket Items
        $('.player-pocket .player-pocket-items').append(`<div data-slot="${i}" class="item-box"></div>`)
    }
    for(i=13;i<AXFW.Inventory.MaxSlots+13;i++){///Main-Inventory
        $('.player-inventory .player-items').append(`<div data-slot="${i}" class="item-box"></div>`)
    }
    for(i=1;i<(other != undefined && other.slots || AXFW.Inventory.MaxSlots)+1;i++){//Other-Inventory
        $('.other-inventory .other-items').append(`<div data-other-slot="${i}" class="item-box"></div>`)
    }
    if(other){
        $('.cloth-inv').fadeOut();$('.crafting-inventory').fadeOut();$('.other-inventory').fadeIn().attr('data-inventory',other.id)
        $.each(other.items,function(k,v){
            if(v != null){
                $('.inventory').find(`[data-other-slot="${v.slot}"]`).html(`
                    <img src="items/${v.image}.png">
                    <div class="item-amount">${v.amount}</div>
                    <div style="background:${GetQualityColor(v.info.quality)}" class="item-quality"></div>
                `).removeData().data(v)
            }
        })
    }else{
        $('.cloth-inv').fadeIn();$('.other-inventory').fadeOut();$('.crafting-inventory').fadeOut()
    }
    $.each(items,function(k,v){
        if(v != null){
            $('.inventory').find(`[data-slot="${v.slot}"]`).html(`
                <img src="items/${v.name}.png">
                <div class="item-amount">${v.amount}</div>
                <div style="background:${GetQualityColor(v.info.quality)}" class="item-quality"></div>
            `).removeData().data(v)
        }
    })
    AXFW.Inventory.WeightProgress(plyweight)
    AXFW.Inventory.Utils()
}
AXFW.Inventory.Utils = function(){
    $('.item-box').each(function(){
        if($(this).data('name')){
            $(this).draggable({helper: 'clone',appendTo: ".inventory",revert: 'invalid',containment: 'document'})
        }
    })
    $(".item-box").droppable({
        hoverClass: 'button-hover',
        drop: function(event, ui) {
            if(!isOverflowing(event, $(this).parent().parent()) || $(this).parent().parent().attr('data-inventory') != 'player'){
                var toinventory = $(this).parent().parent().attr('data-inventory')
                var frominventory = ui.draggable.parent().parent().attr('data-inventory')
                var amount = parseInt($('#amount').val());
                if (amount != 0 && $(this).data('name') == ui.draggable.data('name') || $(this).data('name') == undefined || amount == 0 || isNaN(amount) ){
                    if(frominventory == 'player' && toinventory == 'player'){
                        $.post('https://'+GetParentResourceName()+'/SetInventoryData',JSON.stringify({
                            toslot:$(this).data('slot'),
                            fromslot:ui.draggable.data('slot'),
                            frominventory:frominventory,
                            toinventory:toinventory,
                            amount:amount
                        }))
                    }else if(frominventory == 'player' && toinventory != 'player'){
                        $.post('https://'+GetParentResourceName()+'/SetInventoryData',JSON.stringify({
                            toslot:$(this).data('other-slot'),
                            fromslot:ui.draggable.data('slot'),
                            frominventory:frominventory,
                            toinventory:toinventory,
                            amount:amount
                        }))
                    }else if(frominventory != 'player' && toinventory == 'player'){
                        $.post('https://'+GetParentResourceName()+'/SetInventoryData',JSON.stringify({
                            toslot:$(this).data('slot'),
                            fromslot:ui.draggable.data('other-slot'),
                            frominventory:frominventory,
                            toinventory:toinventory,
                            amount:amount
                        }))
                    }else if(frominventory != 'player' && toinventory != 'player'){
                        $.post('https://'+GetParentResourceName()+'/SetInventoryData',JSON.stringify({
                            toslot:$(this).data('other-slot'),
                            fromslot:ui.draggable.data('other-slot'),
                            frominventory:frominventory,
                            toinventory:toinventory,
                            amount:amount
                        }))
                    }
                }
                AddLog(`Moving Item(${!isNaN(amount) && amount || 'All'}) from ${frominventory} to ${toinventory}`)
            }
        }
    });
    $('.use-item').off().droppable({
        drop:function(event,ui){
            $.post('https://'+GetParentResourceName()+'/UseItem',JSON.stringify({
                inventory:ui.draggable.parent().parent().attr('data-inventory'),
                item:ui.draggable.attr('data-slot')
            }))
        }
    })
    $('.drop-item').off().droppable({
        drop:function(event,ui){
            $.post('https://'+GetParentResourceName()+'/DropItem',JSON.stringify({
                inventory:ui.draggable.parent().parent().attr('data-inventory'),
                item:ui.draggable.attr('data-slot')
            }))
        }
    })
    $('.cloth-items .item-box').off().click(function(){
        $.post('https://'+GetParentResourceName()+'/ChangeVariation',JSON.stringify({component:$(this).attr('id')}))
    })
    $('.crafting-toggle').off().click(AXFW.Inventory.OpenCrafting)
    $('#search').off().bind('input',function(){
        var value = $(this).val()
        $('.item-box').each(function(){
            if ($(this).parent().attr('class') != 'cloth-items'){
                if($(this).data('name') && $(this).data('name').includes(value)){
                    $(this).css('opacity','1.0')
                }else{
                    $(this).css('opacity','0.4')
                }
                if(value == '' || !value){
                    $(this).css('opacity','1.0')
                }
            }
        })
    })
    $('.item-box').each(function(){
        var data = Object.assign({}, $(this).data())
        if (data.name){
            $(this).attr('title',`
                <h>${data.label}<h>
                <span style="display:block;font-size:1.5vh">Amount ${data.amount}</span>
            `
            ).tooltip({content:$(this).attr('title'),track:true})
            if(data.info && data.info.quality){
                $(this).attr('title',$(this).attr('title')+`<span style="display:block;font-size:1.5vh">Quality ${data.info.quality}</span>`).tooltip({content:$(this).attr('title'),track:true})
            }
        }
    })
    $('.settings i').off().click(function(){
        $('.settings-tab').fadeToggle()
        $('#tooltip-checkbox').off().change(function(){
            if($(this).prop('checked')){
                $('head').append(`<style id="head-tooltip-setting">.ui-tooltip{visibility: hidden;}</style>`)
            }else{
                $('#head-tooltip-setting').remove()
            }
        })
        $('#blur-checkbox').off().change(function(){
            if($(this).prop('checked')){
                $('.bg').css('backdrop-filter','blur(15vh)')
            }else{
                $('.bg').css('backdrop-filter','none')
            }
        })
    })
    $(".item-amount").each(function(){var t=$(this).html().length;4==t?$(this).css({top:"2vh"}):3==t?$(this).css({top:"2.2vh"}):2==t?$(this).css({top:"2.5vh"}):1==t&&$(this).css({top:"2.7vh"})});
}
AXFW.Inventory.Close = function(){
    $.post('https://'+GetParentResourceName()+'/CloseInventory')
    $('.ui-tooltip').hide()
}
AXFW.Inventory.WeightProgress = function(value){
    bar.animate(value/100)
    AnimateWeight('.inventory-weight-head',value)
}
const CraftingItems = AXFW.Inventory.CraftingItems
AXFW.Inventory.OpenCrafting = function() {
    $('.cloth-inv').fadeOut();$('.other-inventory').fadeOut()
    $('.crafting-inventory').fadeIn()
    $('.crafting-inventory .crafting-items').html('')
    $.each(CraftingItems,function(k,v){
        AddCraftingElement(k,v)
    })
}
var HotBarTimeOut
AXFW.Inventory.OpenHotbar = function(data){
    clearTimeout(HotBarTimeOut)
    $('.quick-hotbar').find('.item-box').remove()
    $('.quick-hotbar').fadeIn().animate({right:'1vw'})
    for(i=1;i<7;i++){
        $('.quick-hotbar').append(`
        <div data-hotbar-slot="${i}" class="item-box">
            <div class="item-hotbar-key">${i}</div>
        </div>
        `)
    }
    $.each(data,function(k,v){
        if(v){
            $('.quick-hotbar').find(`[data-hotbar-slot=${v.slot}]`).html(`
                <div class="item-hotbar-key">${v.slot}</div>
                <img src="items/${v.image}">
                <div class="item-amount">${v.amount}</div>
            `)
        }
    })
    HotBarTimeOut = setTimeout(function(){
        $('.quick-hotbar').animate({right:'-10vw'})
        $('.quick-hotbar').fadeOut()
    },3000)
}

////UTILS 
AnimateWeight = async function(element,end) {
    $(element).animate({
        Counter: end
    }, {duration: 500,easing: 'swing',
        step: function (now) {
            $(this).html(`${Math.ceil(now)}.0 /<span style="opacity: 0.5;"> 100.0</span>`);
        }
    });
}

AddLog = function(log){
    $('.logs').prepend(`<p>${log}</p>`)
}

isOverflowing = function(event, $droppableContainer){
    var cTop = $droppableContainer.offset().top;var cLeft = $droppableContainer.offset().left;var cBottom = cTop + $droppableContainer.height();var cRight = cLeft + $droppableContainer.width();
    if (event.pageY >= cTop && event.pageY <= cBottom && event.pageX >= cLeft && event.pageX <= cRight){return false;}else{return true;}
}

AddCraftingElement = function(item,recipe){
    $('.crafting-inventory .crafting-items').prepend(`
        <div data-crafting-item="${item}" class="item-crafting">
            <div class="left">
                <div class="item-box">
                    <img src="items/${item}.png">
                </div>
                <div class="craft-button">
                    Craft
                </div>
            </div>
            <div class="right"></div>
        </div>
    `)
    var craftingelement = $('.crafting-items').find(`[data-crafting-item=${item}]`)
    $.each(recipe,function(k,v){
        craftingelement.find('.right').append(`
            <div class="recipe">
                <span>
                    <img src="items/${v.image}">
                    ${v.amount}x ${v.label}
                </span>
            </div>
        `)
    })
    craftingelement.off().find('.craft-button').click(function(){
        $.post('https://'+GetParentResourceName()+'/CraftItem',JSON.stringify({
            item:item,
            recipe:recipe
        }))
    })
}

GetQualityColor = function(quality){
    return quality >= 100 && '#2ACAFF' || quality < 90 && quality >= 75 && '#73f1ce' || quality < 75 && quality >= 50 && '#ffca51' || quality < 50 && quality >= 25 && '#ef8830' || quality < 25 && '#ff3b00'
}

window.addEventListener('message', function(event) {
    switch(event.data.action) {
        case 'open':
            AXFW.Inventory.Open(event.data.items,false,event.data.other,event.data.plyweight)
            break;
        case 'close':
            $('.inventory').fadeOut()
            break;
        case 'refresh':
            AXFW.Inventory.Open(event.data.items,true,event.data.other,event.data.plyweight)
            break;
        case 'hotbar':
            AXFW.Inventory.OpenHotbar(event.data.items)
            break;
    }
})

$(document).on('keydown', function(event) {
    switch(event.keyCode) {
        case 27: // ESC
        AXFW.Inventory.Close()
        break;
    }
})