from django import forms

#  views.searchbox is using the following code
#  if 'author' in form.cleaned_data and form.cleaned_data['author']:
#  search_opts['Letter.letter_author__fulltext_terms'] = '%s' % form.cleaned_data['author']

class ArticleSearchForm(forms.Form):
    "Search the text"
    keyword = forms.CharField(required=False)
    title = forms.CharField(required=False)
    article_date = forms.CharField(required=False)
       
    def clean(self):
        """Custom form validation."""
        cleaned_data = self.cleaned_data

        keyword = cleaned_data.get('keyword')
        title = cleaned_data.get('title')
        article_date = cleaned_data.get('article_date')
        
        "Validate at least one term has been entered"
        if not keyword and not title and not article_date:
            del cleaned_data['keyword']
            del cleaned_data['title']
            del cleaned_data['article_date']
            
            raise forms.ValidationError("Please enter search terms.")

        return cleaned_data

class IllustrationSearchForm(forms.Form):
    "Search the illustrations"
    keyword = forms.CharField(required=False)
    illustration_date = forms.CharField(required=False)
       
    def clean(self):
        """Custom form validation."""
        cleaned_data = self.cleaned_data

        keyword = cleaned_data.get('keyword')
        illustration_date = cleaned_data.get('illustration_date')
        
        "Validate at least one term has been entered"
        if not keyword and not illustration_date:
            del cleaned_data['keyword']
            del cleaned_data['illustration_date']
            
            raise forms.ValidationError("Please enter search terms.")

        return cleaned_data
