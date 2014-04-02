from django import forms

#  views.searchform is using the following code
#  if 'keyword' in form.cleaned_data and form.cleaned_data['keyword']:
#  search_opts['fulltext_terms'] = '%s' % form.cleaned_data['keyword']

class SearchForm(forms.Form):
    "Search the text"
    keyword = forms.CharField(required=False)
    title = forms.CharField(required=False)
    article_date = forms.CharField(required=False)
    illustration_date = forms.CharField(required=False)
    illustration_subject = forms.CharField(required=False)
       
    def clean(self):
        """Custom form validation."""
        cleaned_data = self.cleaned_data

        keyword = cleaned_data.get('keyword')
        title = cleaned_data.get('title')
        article_date = cleaned_data.get('article_date')
        illustration_date = cleaned_data.get('illustration_date')
        illustration_subject = cleaned_data.get('illustration_subject')
        
        "Validate at least one term has been entered"
        if not keyword and not title and not article_date and not illustration_date:
            del cleaned_data['keyword']
            del cleaned_data['title']
            del cleaned_data['article_date']
            del cleaned_data['illustration_date']
            del cleaned_data['illustration_subject']
            
            raise forms.ValidationError("Please enter search terms.")

        return cleaned_data
