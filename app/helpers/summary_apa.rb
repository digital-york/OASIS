class SummaryApa < Apa
  def self.get_summary_reference_html(writers,
                                      summary_publication_year,
                                      title,
                                      oasis_publication_name,
                                      authors,
                                      publication_year,
                                      journal,
                                      authority_value = true)
    j_string = html_italic(journal) + '. '
    j_string = html_italic(get_journal_string(journal)) if authority_value == true

    get_author_string(writers) +
      get_summary_year_string(summary_publication_year) +
      get_title_string(title) +
      html_italic(oasis_publication_name) + ' of ' +
      get_author_string(authors) +
      get_publication_year_string(publication_year) + ' in ' +
      j_string +
      '.'
  end

  def self.get_summary_with_other_journal_name_reference_html(writers,
                                                              summary_publication_year,
                                                              title,
                                                              oasis_publication_name,
                                                              authors,
                                                              publication_year,
                                                              other_journal_name,
                                                              other_journal_url,
                                                              authority_value = true)
    j_string = html_italic(other_journal_name) + '. '
    j_string = html_italic(get_other_journal_string(other_journal_name, other_journal_url)) if authority_value == true

    get_author_string(writers) +
      get_summary_year_string(summary_publication_year) +
      get_title_string(title) +
      html_italic(oasis_publication_name) + ' of ' +
      get_author_string(authors) +
      get_publication_year_string(publication_year) + ' in ' +
      j_string +
      '.'
  end

  def self.get_publication_year_string(year)
    return '' if year.nil?

    '(' + year + ') '
  end

  def self.get_summary_year_string(year)
    return '(' + year + '). ' if !year.nil? && (year != '')

    ''
  end

  def self.get_journal_string(journal)
    unless journal.nil?
      if journal.starts_with?('http') || (journal.to_i <= 0)
        return get_html_link(journal, GenericLocalAuthorityService.id_to_label('journals', journal))
      else
        return get_html_link(journal, GenericLocalAuthorityService.id_to_label('journals', journal.to_i))
      end
    end
    ''
  end
end
