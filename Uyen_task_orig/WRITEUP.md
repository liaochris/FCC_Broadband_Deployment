**Five deliverables –**

1. **top 25+ provider county share distribution**
2. **technology county share distribution**
3. **technology tract share distribution (code form only)**
4. **provider tract share distribution (code form only)**
5. **Summary statistics on counties affected by mergers**

First, I found the top 25 providers (using the `ProviderName` attribute) from the June 2016 FCC Form 477 dataset. This is done in &quot;topProviders.R&quot; (not provided) and exports a file called &quot;topProviders.csv&quot; (provided). The actual file contains slightly more than 25 providers because there are some providers that were manually added because they were not in the dataset.

To replicate, there are two steps.

1. Change the command on line 23 (setwd) to whatever directory you wish to work in.
2. Download the June 2016 V4 csv and put it in a folder called &quot;FCC Data&quot; in your directory.

**Note: all information mergers described here together**

**Crosswalk for names**

1. Manually performed name crosswalks

**Merger descriptions**

1. Century link/level 3 merger – Level 3 not in dataset
2. Verizon and XO merger on June 2017
  1. Thus all Verizon/XO counties marked as -1 on December 2016, 1 on December 2017
3. Charter and Time Warner merger on June 2016
  1. Thus all Charter/Time Warner counties marked as -1 on December 2015, 1 on December 2016
4. Charter and Bright House merger on June 2016
  1. Thus all Charter/Bright House counties marked as -1 on December 2015, 1 on December 2016
5. Frontier and Verizon – conflicts with Verizon overlap
6. AT&amp;T and direcTV – direcTV not available
7. AT&amp;T and Frontier merger on December 2014
  1. Thus all AT&amp;T/Frontier counties marked as -1 on June 2014, 1 on June 2015

Deliverable #1 **top 25+ provider county share distribution (joined \_provider.csv)**

1. Read in all the files for the FCC from June 2014 to December 2019, filtered it so that only data regarding providers from our list of top 25+ providers were included
2. Grouped data by county (**assumption: each block within a county is equally weighted)**
  1. ie: county 1 has 2 blocks:
    1. Block 1: Provider A, provider B
    2. Block 2: Provider B
  2. County share provider (step 4) = 33% A, 67% B
3. Joined FCC data with block population data
4. Calculated share of provider in each county
5. Added merger indicators (1 in time period for provider right after merger, -1 in time period for provider during/right before merger)

Deliverable #2 **technology county share distribution (joined\_wide\_tech.csv)**

1. Read in all the files for the FCC from June 2014 to December 2019
2. Grouped data by county (**assumption: each block within a county is equally weighted)**
  1. ie: county 1 has 2 blocks:
    1. Block 1: Tech A, Tech B
    2. Block 2: Tech B, Tech C
  2. County share provider (step 4) = 25% A, 50% B, 25% C
3. Joined FCC data with block population data
4. Calculated share of technology in each county
5. Stored in &quot;joined\_wide\_tech.csv&quot;

Deliverable #3 **technology tract share distribution (code form only, in provider\_tech\_shares.R)**

1. Read in all the files for the FCC from June 2014 to December 2019
2. Joined FCC data with block population data
3. Grouped tech by tract, while weighting for the population of the blocks in each tract
  1. ie: county 1 has 2 blocks:
    1. Block 1: Tech A, Tech B, 100 population
    2. Block 2: Tech A, 200 population
  2. Tract share tech (step 4) = 83.33% A, 16.67% B
4. Calculated share of technology in each tract

**Replication instructions**

To run on Mercury server, change line 23 (setwd) to the relevant directory. Code assumes that all data files are in a folder called FCC Data. If this is not the case, either create such a folder and move data into it, or change lines 26/27 by changing dir(&quot;FCC Data/&quot;) -\&gt; dir() and paste(&quot;FCC Data/&quot;, i, sep = &quot;&quot;) -\&gt; i.

Deliverable #4 **provider tract share distribution (code form only, in provider\_tech\_shares.R)**

1. Read in all the files for the FCC from June 2014 to December 2019
2. Joined FCC data with block population data
3. Grouped tech by tract, while weighting for the population of the blocks in each tract
  1. ie: county 1 has 2 blocks:
    1. Block 1: Provider A, Provider B, 100 population
    2. Block 2: Provider A, Provider C, 200 population
  2. Tract share tech (step 4) = 50% Provider A, 16.67% Provider B, 33.33% Provider C
4. Calculated share of provider in each tract
5. Added merger indicators

**Replication instructions**

To run on Mercury server, change line 23 (setwd) to the relevant directory. Code assumes that all data files are in a folder called FCC Data. If this is not the case, either create such a folder and move data into it, or change lines 26/27 by changing dir(&quot;FCC Data/&quot;) -\&gt; dir() and paste(&quot;FCC Data/&quot;, i, sep = &quot;&quot;) -\&gt; i.

Deliverable #5

Summary statistics **listed here:**

**Some of these are a bit weird, not sure why**

Verizon and XO merger on June 2017
  1. 162 counties with Verizon December 2016
  2. 162 counties with Verizon December 2017
  3. 0 counties with XO December 2016
  4. 0 counties with XO December 2017
Charter and Time Warner merger on June 2016
  1. 667 counties with Charter Communications December 2015
  2. 1169 counties with Charter Communications December 2016
  3. 536 counties with Time Warner December 2015
  4. 0 counties with Time Warner December 2015
Charter and Bright House merger on June 2016
  1. 667 counties with Charter Communications December 2015
  2. 1169 counties with Charter Communications December 2016
  3. 50 counties with BrightHouse December 2015
  4. 0 counties with Brighthouse December 2016
AT&amp;T and Frontier merger on December 2014
  1. 0 counties with AT&amp;T June 2014
  2. 1377 counties with AT&amp;T June 2015
  3. 0 counties with Frontier June 2014
  4. 741 counties with Frontier June 2015