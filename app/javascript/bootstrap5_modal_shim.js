// Bootstrap 5 Modal Shim for jQuery .modal() compatibility
// This allows Bootstrap 4 style jQuery modal calls to work with Bootstrap 5

(function($) {
  if (typeof $ === 'undefined') return;

  $.fn.modal = function(action) {
    return this.each(function() {
      const element = this;
      let modalInstance = bootstrap.Modal.getInstance(element);

      if (!modalInstance) {
        modalInstance = new bootstrap.Modal(element);
      }

      if (action === 'show') {
        modalInstance.show();
      } else if (action === 'hide') {
        modalInstance.hide();
      } else if (action === 'toggle') {
        modalInstance.toggle();
      }
    });
  };
})(jQuery);
