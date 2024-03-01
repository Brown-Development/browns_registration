document.addEventListener('DOMContentLoaded', function () {
    $('#container').hide();
    $('#ins-container').hide();

    const plate = document.getElementById('plate');
    const owner = document.getElementById('owner');
    const vin = document.getElementById('vin');
    const date = document.getElementById('date');
    const msg = document.getElementById('msg');

    const insplate = document.getElementById('ins-plate');
    const insowner = document.getElementById('ins-owner');
    const insvin = document.getElementById('ins-vin');
    const insdate = document.getElementById('ins-date');
    const insmsg = document.getElementById('ins-msg');

    window.addEventListener('message', function(event) {
        console.log("Message received:", event.data);
        let data = event.data;
        if (data.show === 'reg') {
            plate.innerHTML = 'Plate: ' + data.plate;
            owner.innerHTML = 'Owner: ' + data.name;
            vin.innerHTML = 'VIN: ' + data.vin;
            date.innerHTML = 'REGISTRATION DATE: ' + data.date;
            msg.innerHTML = 'REGISTRATION SHALL EXPIRE ' + data.msg;
            $('#container').show();
        } else if (data.show === 'ins') {
            insplate.innerHTML = 'Plate: ' + data.plate;
            insowner.innerHTML = 'Owner: ' + data.name;
            insvin.innerHTML = 'VIN: ' + data.vin;
            insdate.innerHTML = 'PAYMENT DATE: ' + data.date;
            insmsg.innerHTML = 'INSURANCE SHALL EXPIRE ' + data.msg;
            $('#ins-container').show();
        } else if (data.show === 'hide') {
            $('#container').hide();
            $('#ins-container').hide();
            [plate, owner, vin, date, msg, insplate, insowner, insvin, insdate, insmsg].forEach(el => el.innerHTML = '');
        }
    });
});
