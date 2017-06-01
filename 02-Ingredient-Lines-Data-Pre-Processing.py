
# coding: utf-8

# # Project Valid Ingredients Lines.
# This notebook will pre-process the data to create a file that will be used to build models.

# ## Data.
# Data has been manually labeled using CrowdFlower and be found here:
# 
# gs://"kadaif.getwellio.com/kadaif/datasets/ingredients/labeled_lines/job_995939 2.json"

# In[1]:

reset -fs


# In[2]:

import re
import json
import pprint
import operator
import itertools
import pickle
import numpy as np
import pandas as pd
import seaborn as sns
import prettypandas as pretty
import datalab.bigquery as bq
import matplotlib.pyplot as plt
sns.set_style('white')
get_ipython().magic(u'matplotlib inline')


# Reading data from a bucket.

# In[3]:

get_ipython().run_cell_magic(u'storage', u'read --variable ingredients --object gs://"kadaif.getwellio.com/kadaif/datasets/ingredients/labeled_lines/job_995939 2.json"', u'')


# We create a list from the json file.

# In[4]:

ingredients = [json.loads(x) for x in ingredients.splitlines()]


# In[5]:

def process_json(record):
    """
    This function will create a dictionary to store relevant data point from the json elements, which is everything under 'data'.
    After that, we will store all information under 'results', 'judgments'.
    """
    ingredient_line_info = {'ingredient_line_entity':record['data']['entities_ingredient_entity'],
              'ingredient_line_frequency': record['data']['entities_ingredient_entity_frequency'],
              'ingredient_line': record['data']['lines_line'],
              'ingredient_url': record['data']['lines_url']}  
  
    judgments = record['results']['judgments']
  
    response = []
    for judgment in judgments:
        if 'a_is_a_valid_ingredient_line' in judgment['data']:
            item_info = dict(ingredient_line_info)
        cf_data = judgment['data']
        item_info['line_item_info_valid'] = cf_data.get('a_is_a_valid_ingredient_line')
        item_info['line_item_info_other_information'] = cf_data.get('what_information_is_present_in_the_invalid_ingredient_line')
        
        response.append(item_info)
  
    return response   


# We process of items from the json file.

# In[6]:

results = []
for item in ingredients:
    results.extend(process_json(item))


# One item from the dictionary is a list ('line_item_info_other_information'), so we will convert it into a string.

# In[7]:

for item in results:
    if item['line_item_info_other_information']:
        item['line_item_info_other_information'] = ', '.join(item['line_item_info_other_information'])


# We create a pandas dataframe from our list.

# In[8]:

ingredient_data = pd.DataFrame(results)


# We remove duplicates.

# In[9]:

ingredient_data = ingredient_data.drop_duplicates()


# We create a new dataframe with just the columns relevant so it can be used to build models later on.

# In[10]:

ingredient_data_features_labels = ingredient_data[['ingredient_line_entity', 'line_item_info_other_information', 'line_item_info_valid']]


# In[11]:

ingredient_data_features_labels.head()


# We rename the columns of the dataframe.

# In[12]:

new_column_names = ['X', 'other_information', 'labels']


# In[13]:

ingredient_data_features_labels.columns = new_column_names


# In[14]:

ingredient_data_features_labels.head()


# We binarize the labels.

# In[15]:

ingredient_data_features_labels['y'] = ingredient_data_features_labels['labels'].apply(lambda x: 0 if x == 'no' else 1)


# In[16]:

ingredient_data_features_labels.head()


# We remove a column.

# In[17]:

del ingredient_data_features_labels['labels']


# In[18]:

ingredient_data_features_labels.head()


# Saving the file as picke.

# In[19]:

ingredient_data_features_labels.to_pickle('ingredient_data_features_labels.txt')


# Copying file to a bucket in storage.

# In[20]:

get_ipython().system(u"gsutil cp 'ingredient_data_features_labels.txt' 'gs://wellio-kadaif-valid-ingredient-lines'")


# In[ ]:



