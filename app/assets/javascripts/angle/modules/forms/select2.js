// Select2
// -----------------------------------

(function() {
    'use strict';

    $(initSelect2);

    function initSelect2() {

        if (!$.fn.select2) return;

        // Select 2

        $('#user_company_id').select2({
            theme: 'bootstrap4'
        });

        $('#q_job_category_id_eq').select2({
            theme: 'bootstrap4'
        });

        $('#q_user_id_eq').select2({
            theme: 'bootstrap4'
        });

        $('#q_job_id_eq').select2({
            theme: 'bootstrap4'
        });


    }

})();