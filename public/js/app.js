(function ($) {
  'use strict';
  $(document).foundation();

  $('.send-test-report').on('click', function (event) {
    event.preventDefault();
    $.ajax('/', {
      method: 'POST',
      mimeType: 'application/csp-report',
      data: '{"csp-report":{"document-uri":"https://example.com/foo/bar","referrer":"https://www.google.com/","violated-directive":"default-src self","original-policy":"default-src self; report-uri /csp-hotline.php","blocked-uri":"http://evilhackerscripts.com"}}',

      success: function (data, textStatus, jqXHR) {
        alert('it worked!');
      },
      error: function (jqXHR, textStatus, errorThrown) {
        alert('Error :(');
        console.log(textStatus + "\n" + errorThrown);
      }
    });
  });

})(jQuery);
