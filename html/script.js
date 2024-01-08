document.addEventListener('DOMContentLoaded', function () {
    $('#container').hide()
    $('#ins-container').hide()

    const plate = document.getElementById('plate')
    const owner = document.getElementById('owner')
    const vin = document.getElementById('vin')
    const date = document.getElementById('date')
    const msg = document.getElementById('msg')

    const insplate = document.getElementById('ins-plate')
    const insowner = document.getElementById('ins-owner')
    const insvin = document.getElementById('ins-vin')
    const insdate = document.getElementById('ins-date')
    const insmsg = document.getElementById('ins-msg')
    
    window.addEventListener('message', function(event) {
        if (event.data.show === 'reg') {
            let data = event.data 

            plate.innerHTML = data.plate 

            owner.innerHTML = data.name 

            vin.innerHTML = data.vin
            
            date.innerHTML = data.date

            msg.innerHTML = data.msg


            $('#container').show()

        }
    })

    window.addEventListener('message', function(event) {
        if (event.data.show === 'ins') {
            let data = event.data 

            insplate.innerHTML = data.plate 

            insowner.innerHTML = data.name 

            insvin.innerHTML = data.vin
            
            insdate.innerHTML = data.date

            insmsg.innerHTML = data.msg


            $('#ins-container').show()

        }
    })

    window.addEventListener('message', function(event) {
        if (event.data.show === 'hide') {
            $('#container').hide()
            $('#ins-container').hide()

            plate.innerHTML = ''

            owner.innerHTML = ''

            vin.innerHTML = ''

            date.innerHTML = ''

            msg.innerHTML = ''

            insplate.innerHTML = ''

            insowner.innerHTML = ''

            insvin.innerHTML = ''
            
            insdate.innerHTML = ''

            insmsg.innerHTML = ''

        }
    })

})