$(function() {
    $( "#accordion" ).accordion();

    $(".homepage_div").click(function() {
        var status_elt = $(this).find('input');
        if (status_elt.val() == "open") {
            $(this).css('height', '2.5em');
            status_elt.val('close');
        } else {
            $(this).css('height', 'auto');
            status_elt.val('open');
        }
        return false;
    });

    $("#homepage_submit").click(function() {
        window.location.href = '/new_summary';
    });

    $("#homepage_search").click(function() {
        window.location.href = '/catalog';
    });

    <!-- Show hiden IRIS url field -->
    if( $("#summary_materials_on_iris_yes").val()=='Yes'){
        $("#iri_url_div").css("display","block");
    }
    $("#summary_materials_on_iris_yes").click(function(){
        if( $(this).val()=='Yes'){
            $("#iri_url_div").css("display","block");
        }
    });
    $("#summary_materials_on_iris_no").click(function(){
        if( $(this).val()=='No'){
            $("#iri_url_div").css("display","none");
        }
    });

    // show/hide other topic fields
    function check_topic_other_fields() {
        var t = $('#summary_summary_general_research_area option').filter(':selected').text();
        if(t.endsWith('Other')) {
            $("#topic_other_div").css("display","block");
        }else{
            $("#topic_other_div").css("display","none");
        }
    }
    <!-- Show hiden 'other' topic field -->
    $("#summary_summary_general_research_area").click(function(){
        check_topic_other_fields();
    });
    <!-- check if needs to show other field on load of the page -->
    check_topic_other_fields();

    // show/hide other journal name fields
    function check_publication_journal_name_other_fields() {
        var t = $('#summary_publication_journal_name option').filter(':selected').text();
        if(t.endsWith('Other')) {
            $("#publication_journal_name_other_div").css("display","block");
        }else{
            $("#publication_journal_name_other_div").css("display","none");
        }
    }
    <!-- Show hiden 'other' journal field -->
    $("#summary_publication_journal_name").click(function(){
        check_publication_journal_name_other_fields();
    });
    <!-- check if needs to show other journal name field on load of the page -->
    check_publication_journal_name_other_fields();

    // show/hide other proficiency fields
    function check_participants_proficiency_other_fields() {
        if($('[id^=summary_participants_proficiency_]').eq(-2).is(':checked')) {
            $("#participants_proficiency_other_div").css("display","block");
        }else{
            $("#participants_proficiency_other_div").css("display","none");
        }
    }
    <!-- Show hiden 'other' proficiency field -->
    var participants_proficiency_last = $("[id^=summary_participants_proficiency_]").eq(-2);
    participants_proficiency_last.click(function(){
        check_participants_proficiency_other_fields();
    });
    <!-- check if needs to show proficiency other field on load of the page -->
    check_participants_proficiency_other_fields();

    // show/hide language_summary_written_in_other fields
    function check_language_summary_written_in_other_fields() {
        var t = $('#summary_language_summary_written_in option').filter(':selected').text();
        if(t.endsWith('Other')) {
            $("#language_summary_written_in_other_div").css("display","block");
        }else{
            $("#language_summary_written_in_other_div").css("display","none");
        }
    }
    <!-- Show hiden language_summary_written_in_other field -->
    $("#summary_language_summary_written_in").click(function(){
        check_language_summary_written_in_other_fields();
    });
    <!-- check if needs to show summary_language_summary_written_in_other field on load of the page -->
    check_language_summary_written_in_other_fields();


    // show/hide participants_type_other fields
    function check_participants_type_other_fields() {
        var t = $('#summary_participants_type option').filter(':selected').text();
        if(t.endsWith('Other')) {
            $("#participants_type_other_div").css("display","block");
        }else{
            $("#participants_type_other_div").css("display","none");
        }
    }
    <!-- Show hiden participants_type_other field -->
    $("#summary_participants_type").click(function(){
        check_participants_type_other_fields();
    });
    <!-- check if needs to show participants_type_other field on load of the page -->
    check_participants_type_other_fields();


    // show/hide of_likely_interest_to_other fields
    function check_of_likely_interest_to_other_fields() {
        var t = $('#summary_of_likely_interest_to option').filter(':selected').text();
        if(t.endsWith('Other')) {
            $("#of_likely_interest_to_other_div").css("display","block");
        }else{
            $("#of_likely_interest_to_other_div").css("display","none");
        }
    }
    <!-- Show hiden participants_type_other field -->
    $("#summary_of_likely_interest_to").click(function(){
        check_of_likely_interest_to_other_fields();
    });
    <!-- check if needs to show of_likely_interest_to_other_fields on load of the page -->
    check_of_likely_interest_to_other_fields();


    // show/hide participants_firstlanguage_other fields
    function check_participants_firstlanguage_other_fields() {
        var t = $('#summary_participants_firstlanguage option').filter(':selected').text();
        if(t.endsWith('Other')) {
            $("#participants_firstlanguage_other_div").css("display","block");
        }else{
            $("#participants_firstlanguage_other_div").css("display","none");
        }
    }
    <!-- Show hiden participants_firstlanguage_other field -->
    $("#summary_participants_firstlanguage").click(function(){
        check_participants_firstlanguage_other_fields();
    });
    <!-- check if needs to show participants_firstlanguage_other on load of the page -->
    check_participants_firstlanguage_other_fields();

    // show/hide participants_targetlanguage_other fields
    function check_participants_targetlanguage_other_fields() {
        var t = $('#summary_participants_targetlanguage option').filter(':selected').text();
        if(t.endsWith('Other')) {
            $("#participants_targetlanguage_other_div").css("display","block");
        }else{
            $("#participants_targetlanguage_other_div").css("display","none");
        }
    }
    <!-- Show hiden participants_targetlanguage_other field -->
    $("#summary_participants_targetlanguage").click(function(){
        check_participants_targetlanguage_other_fields();
    });
    <!-- check if needs to show participants_targetlanguage_other on load of the page -->
    check_participants_targetlanguage_other_fields();

    <!-- applying writers' order from summary_summary_writer_all -->
    var all_writers_text = $('#summary_summary_writer_all').val();

    if(all_writers_text && all_writers_text!='') {
        var all_writers = JSON.parse(all_writers_text);
        for(var i in all_writers) {
            // update all writers in the order defined in summary_summary_writer_all
            if(all_writers[i]!='') {
                $('.summary_summary_writer:eq(' + (parseInt(i) + 1) + ')').val(all_writers[i]);
            }
        }
    }

    <!-- applying authors' order from summary_publication_author_all -->
    var all_authors_text = $('#summary_publication_author_all').val();
    if(all_authors_text && all_authors_text!='') {
        var all_authors = JSON.parse(all_authors_text);
        for(var i in all_authors) {
            // update all authors in the order defined in publication_author_all
            if(all_authors[i]!='') {
                $('.summary_publication_author:eq(' + (parseInt(i) + 1) + ')').val(all_authors[i]);
            }
        }
    }

    $("#with_files_submit").click(function(){
        // before submitting changes, update summary_summary_writer_all.
        var writers = [];
        $("input[name='summary[summary_writer][]']").each(function() {
            if($(this).val()!='') {
                writers.push($(this).val());
            }
        });
        // update hidden field 'summary_summary_writer_all' value
        $('#summary_summary_writer_all').val(JSON.stringify(writers));

        // before submitting changes, update publication_author_all.
        var authors = [];
        $("input[name='summary[publication_author][]']").each(function() {
            if($(this).val()!='') {
                authors.push($(this).val());
            }
        });
        // update hidden field 'publication_author_all' value
        $('#summary_publication_author_all').val(JSON.stringify(authors));
    });
});
