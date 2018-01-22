
# coding: utf-8

# # Creating dataframes to obtain data points required to create KPIs.

# ## Total Number of Recipes and Total Number of Unique Recipes.

# In[ ]:


reset -fs


# In[ ]:


import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
import datalab.bigquery as bq
import google.datalab.bigquery as gbq
import warnings
import re
get_ipython().magic(u'matplotlib inline')


# ### To view all full columns of any dataframe, not truncated, we set the option below:

# In[ ]:


pd.set_option('display.max_colwidth', -1)


# In[ ]:


# To avoid:
# /usr/local/lib/python2.7/dist-packages/seaborn/categorical.py:1424: FutureWarning: remove_na is deprecated and is a private function. Do not use.
# stat_data = remove_na(group_data)
# When printing below chart.
warnings.filterwarnings('ignore')


# ### The best way to find unique recipes is by running this query:

# In[ ]:


get_ipython().magic(u'bq query -n imported_total_unique_recipes -- This is the count of unique recipes.')
SELECT *
FROM (
  SELECT *, ROW_NUMBER() OVER(PARTITION BY id) AS row
  FROM `firebase-wellio.recipes.imported_recipes`
  )
WHERE row = 1


# In[ ]:


duplicated_recipes_df = imported_total_unique_recipes.execute(output_options=gbq.QueryOutput().dataframe()).result()


# In[ ]:


get_ipython().magic(u'bq query -n imported_recipes_duplicates -- These are the unique recipes row by row.')
SELECT *
FROM (
  SELECT *, ROW_NUMBER() OVER(PARTITION BY id) AS row
  FROM `firebase-wellio.recipes.imported_recipes`
  )
WHERE row = 1

