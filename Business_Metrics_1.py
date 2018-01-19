
# coding: utf-8

# # Creating dataframes to obtain data points required to create KPIs.

# ## Total Number of Recipes and Total Number of Unique Recipes.

# In[1]:


reset -fs


# In[2]:


import seaborn as sns
import datalab.bigquery as bq
import matplotlib.pyplot as plt
import pandas as pd
import warnings
import re
get_ipython().magic(u'matplotlib inline')


# ### To view all full columns of any dataframe, not truncated, we set the option below:

# In[3]:


pd.set_option('display.max_colwidth', -1)


# ### Getting the count of recipe URLs that have been scrapped from different websites.

# In[4]:


get_ipython().run_cell_magic(u'sql', u'--module num_urls', u'SELECT url, COUNT(url) as num_urls\nFROM [firebase-wellio:recipes.recipes]\nGROUP BY url\nORDER BY num_urls DESC')


# In[5]:


get_ipython().run_cell_magic(u'bigquery', u'execute -q num_urls', u'')


# ### Getting the URLs domain count for all recipes.

# In[6]:


get_ipython().run_cell_magic(u'sql', u'--module recipes_sites_data', u"SELECT SUBSTRING(url, 1, INSTR(url, '.com')+4) as domain_url, COUNT(substring(url, 1, INSTR(url, '.com')+4)) as domain_count\nFROM [firebase-wellio:recipes.recipes]\nWHERE url IS NOT NULL\nGROUP BY domain_url\nORDER BY domain_count DESC")


# In[7]:


get_ipython().run_cell_magic(u'bigquery', u'execute -q recipes_sites_data', u'')


# ### Converting BigQuery into a pandas dataframe.

# In[8]:


recipes_sites_df = bq.Query(recipes_sites_data).to_dataframe()


# In[9]:


# To avoid:
# /usr/local/lib/python2.7/dist-packages/seaborn/categorical.py:1424: FutureWarning: remove_na is deprecated and is a private function. Do not use.
# stat_data = remove_na(group_data)
# When printing below chart.
warnings.filterwarnings('ignore')


# ### Plotting above dataframe.

# In[10]:


sns.set_style("whitegrid")
# Set the plot size in inches.
sns.set(rc={'figure.figsize':(11.7,8.27)})
recipes_plot = sns.barplot(x='domain_count', y='domain_url', data=recipes_sites_df[:7])
plt.setp(recipes_plot.get_xticklabels(), rotation=45);


# ### We create a new dataframe from the 1st one and dropping a column.

# In[11]:


all_recipes_sites_df = bq.Query(num_urls).to_dataframe()


# In[12]:


all_recipes_sites_df.drop('num_urls', axis=1, inplace=True)


# In[13]:


all_recipes_sites_df.head()


# In[14]:


all_recipes_df = all_recipes_sites_df


# In[15]:


all_recipes_df.rename(columns = {'url':'full_recipe_url'}, inplace=True)


# In[16]:


all_recipes_df.head()


# In[17]:


def find_index_char(my_dataframe_element, my_character):
  '''
  This function returns a substring. We provide a column from a dataframe, represented by variable my_dataframe_element,
  and we find all the index positions of a character (represented by variable my_character) in such element.
  This will create a list of all the indices of such character (if more than 1 is found) in the dataframe element, which is 
  represented by the variable list_of_positions. If we want to return the last position of such character, we would return 
  list_of_positions[-1]
  In this case, we will return the sliced element starting at the last index position of the provided character we are interested.
  The unique recipe is at the end of every url, i.e. http://www.food.com/recipe/watermelon-salad-229886, the recipe is watermelon-salad-229886.
  '''
  list_of_positions = [pos for pos, char in enumerate(my_dataframe_element) if char == my_character]
  return my_dataframe_element[list_of_positions[-1]:]


# In[18]:


def find_index_char_hard_coded(my_dataframe_element):
  '''
  This function returns a substring. We provide a column from a dataframe, represented by variable my_dataframe_element,
  and we find all the index positions of a hardcoded character (which is / in this case) in such element.
  This will create a list of all the indices of such character (if more than 1 is found) in the dataframe element, which is 
  represented by the variable list_of_positions. If we want to return the last position of such character, we would return 
  list_of_positions[-1]
  In this case, we will return the sliced element starting at the last index position of the provided character we are interested.
  '''
  list_of_positions = [pos for pos, char in enumerate(my_dataframe_element) if char == '/']
  return my_dataframe_element[list_of_positions[-1]:]


# #### Example of applying above function to the 1st row of the new dataframe. We are interesting in the string after the last '/' as it will be the unique identifier for each recipe.

# In[19]:


all_recipes_df.iloc[0]


# In[20]:


find_index_char(all_recipes_df.iloc[0].to_string(), '/')


# ### Now we create a new column in the dataframe to store the identifier of each recipe.

# In[21]:


all_recipes_df['recipe']=''


# In[22]:


all_recipes_df.head()


# ### We apply the function to 5 rows to see if it works.

# In[23]:


all_recipes_df['recipe'] = all_recipes_df['full_recipe_url'][:5].apply(find_index_char_hard_coded)


# In[24]:


all_recipes_df.head()


# ### Since the function works, we apply it to the entire dataframe column.

# In[25]:


all_recipes_df['recipe'] = all_recipes_df['full_recipe_url'].apply(find_index_char_hard_coded)


# In[26]:


all_recipes_df.tail()


# In[27]:


all_recipes_df.shape


# ### Do we have duplicated recipes?

# In[28]:


all_recipes_df.drop_duplicates().shape


# #### There are no duplicated recipes.

# ### Let's use a different table.

# In[29]:


get_ipython().run_cell_magic(u'sql', u'--module imported_urls', u'SELECT COUNT(url) AS count_urls\nFROM [firebase-wellio:recipes.imported_recipes]\nWHERE url IS NOT NULL')


# In[30]:


get_ipython().run_cell_magic(u'bigquery', u'execute -q imported_urls', u'')


# In[31]:


get_ipython().run_cell_magic(u'sql', u'--module imported_recipes', u"SELECT url, COUNT(url) AS count_urls\nFROM [firebase-wellio:recipes.imported_recipes]\nWHERE url IS NOT NULL AND url <> '#'\nGROUP BY url\nORDER BY count_urls DESC\n-- We limit the number of records since when we export this query to a dataframe, the notebook can't handle 8 million rows.\nLIMIT 1000")


# In[32]:


get_ipython().run_cell_magic(u'bigquery', u'execute -q imported_recipes', u'')


# #### There's a final '/' in some URLs that should be removed.

# In[33]:


get_ipython().run_cell_magic(u'sql', u'--module imported_recipes_no_final_slash', u"SELECT url,\nCASE\n  WHEN RIGHT(url, 1) = '/' THEN LEFT(url, LENGTH(url)-1)\n  ELSE url\nEND\nFROM [firebase-wellio:recipes.imported_recipes]\nWHERE url IS NOT NULL AND url <> '#'\nLIMIT 50")


# In[34]:


get_ipython().run_cell_magic(u'bigquery', u'execute -q imported_recipes_no_final_slash', u'')


# ### Unfortunately, when we try to run above for the entire table, we get:

# #### `HTTP request failed: Response too large to return. Consider setting allowLargeResults to true in your job configuration. For more information, see https://cloud.google.com/bigquery/troubleshooting-errors`

# ### So we need to export into a pandas dataframe and handle it there.

# In[35]:


imported_recipes_sites_df = bq.Query(imported_recipes).to_dataframe()


# In[36]:


del imported_recipes_sites_df['count_urls']


# In[37]:


imported_recipes_sites_df.head()


# In[38]:


imported_recipes_sites_df.shape


# In[39]:


imported_recipes_sites_df.drop_duplicates().shape


# ### Removing final '/' in URL if present:

# In[40]:


def remove_final_slash(my_dataframe_series):
  '''
  Some URLs contain a final /, so we remove it if present.
  '''
  if my_dataframe_series[-1] == '/':
    final_series = my_dataframe_series[0:len(my_dataframe_series)-1]
  else:
    final_series = my_dataframe_series
  return final_series


# In[41]:


imported_recipes_sites_df['recipe'] = imported_recipes_sites_df['url'][:5].apply(remove_final_slash)


# In[42]:


imported_recipes_sites_df.head()


# In[43]:


imported_recipes_sites_df['recipe'] = imported_recipes_sites_df['url'].apply(remove_final_slash)


# In[44]:


imported_recipes_sites_df.tail()


# ### If there's an URL which contains some Google Ad code, we remove it. For example:
# ### `http://www.motherthyme.com/2014/08/bread-pudding.html?utm_source=feedburner&utm_medium=email&utm_campaign=Feed:+motherthyme/BYjd+(Mother+Thyme`

# In[45]:


def remove_utm(my_dataframe_series):
  '''
  This function removes Google Ad Words code from the URL, which is identified by ?utm_source= if present.
  '''
  if '?utm_source=' in my_dataframe_series:
    utm_index = my_dataframe_series.index('?utm_source=')
    final_series = my_dataframe_series[0:utm_index]
  else:
    final_series = my_dataframe_series
  return final_series


# In[46]:


imported_recipes_sites_df['recipe'] = imported_recipes_sites_df['recipe'].apply(remove_utm)


# In[47]:


imported_recipes_sites_df['final_recipe'] = imported_recipes_sites_df['recipe'].apply(find_index_char_hard_coded)


# In[48]:


imported_recipes_sites_df.tail()


# ### We have different domains: .com, .ca...

# In[49]:


def find_index_char_hard_coded_first(my_dataframe_element):
  '''
  This function returns a substring. We provide a column from a dataframe, represented by variable my_dataframe_element,
  and we find all the index positions of a hardcoded character (which is / in this case) in such element.
  This will create a list of all the indices of such character (if more than 1 is found) in the dataframe element, which is 
  represented by the variable list_of_positions. If we want to return the first position of such character, we would return 
  list_of_positions[0]
  In this case, we will return the sliced element starting at the first index position of the provided character we are interested.
  '''
  list_of_positions = [pos for pos, char in enumerate(my_dataframe_element) if char == '/']
  if 'http' or 'https' in my_dataframe_element:
    return my_dataframe_element[0:list_of_positions[2]]


# In[50]:


imported_recipes_sites_df['recipe_domain'] = imported_recipes_sites_df['url'].apply(find_index_char_hard_coded_first)


# In[51]:


imported_recipes_sites_df.head()


# In[52]:


imported_recipes_sites_df.tail()


# In[53]:


imported_recipes_sites_df['recipe_domain'].value_counts()


# ### We create a dataframe to store all URL domains and their counts.

# In[54]:


domains_df = imported_recipes_sites_df['recipe_domain'].value_counts().to_frame()


# In[55]:


domains_df.head()


# In[56]:


domains_df.reset_index(inplace=True)


# In[57]:


domains_df.rename(columns = {'index':'domain', 'recipe_domain':'domain_count'}, inplace=True)


# In[58]:


domains_df.head()


# In[59]:


url_recipes_plot = sns.barplot(x='domain_count', y='domain', data=domains_df[:25])
plt.setp(url_recipes_plot.get_xticklabels(), rotation=45);

