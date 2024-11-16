# README File for Hybrid Recommender System Project

## Project Overview
This project explores the development and implementation of a **Hybrid Recommender System** for Amazon item recommendations. The system combines **content-based filtering** and **collaborative filtering** to address key challenges typically faced in recommender systems: cold start, data sparsity, and the need to handle large datasets efficiently.

---

## Key Challenges and Solutions

### 1. **Cold Start Problem**
- **Challenge**: Difficulty generating accurate recommendations for new users or items with limited interactions or ratings.  
  - *Reference*: Guo (2012) highlights this issue due to insufficient data to understand user preferences.  
- **Solution**: Implemented **content-based filtering** leveraging item descriptions to create profiles for new items.  
  - **Approach**: Used **Word2Vec embeddings** to capture semantic similarity between products based on their names. Recommendations were generated using **cosine similarity** to find the most similar items, and the average rating of these similar items was used to predict ratings.  
  - *Reference*: Roy & Dutta (2022) support the effectiveness of content-based filtering for addressing the cold start problem.

### 2. **Data Sparsity**
- **Challenge**: Sparse rating data makes it challenging to identify reliable similarities between users or items.  
  - *Reference*: Guo (2012) explains that this problem arises due to low interaction frequency.  
- **Solution**: Addressed this issue by integrating **collaborative filtering**, which aggregates patterns across a larger user base, compensating for sparse data.  

### 3. **Large Dataset Management**
- **Challenge**: Efficient processing and analysis of large datasets without compromising system performance.  
- **Solution**: Selected **Singular Value Decomposition (SVD)** as the collaborative filtering method due to its proven scalability and efficiency for handling large datasets.  
  - *Reference*: Casalegno (2022) highlights the advantages of combining collaborative and content-based filtering to enhance system robustness.

---

## Methodology

### 1. **Content-Based Filtering**
- **Tools & Techniques**: 
  - **Word2Vec**: Used to generate vector embeddings for product names to capture semantic relationships.  
  - **Cosine Similarity**: Employed to identify the most similar items to a given product based on Word2Vec embeddings.  
  - **Rating Prediction**: Predicted the rating for a new item by averaging the ratings of its most similar items.

### 2. **Collaborative Filtering**
- **Models Tested**:
  - **SVD (Singular Value Decomposition)**: Chosen for its ability to efficiently handle large datasets and provide robust performance.  
  - **Collaborative Neural Network**: Explored but found less efficient in this context.  
  - **K-Nearest Neighbors (KNN)**: Tested but was computationally expensive for large datasets.  
- **Final Choice**: **SVD** was selected based on experiments showing its superior accuracy and scalability.

### 3. **Hybrid Model**
- Combined the strengths of content-based and collaborative filtering to address the identified challenges.  
- The hybrid model, **Hybrid SVD**, produced meaningful and contextually relevant recommendations by leveraging both item features and user interactions.

---

## Results
- Achieved **94% overall mark** in the assignment, with positive feedback from the lecturer.  
- Ranked **18th out of 95 students** on the Kaggle leaderboard for the assignment.

---

## Project Files
1. **`notebook.ipynb`**: The main implementation notebook containing the code for:
   - Content-based filtering
   - Collaborative filtering models
   - Hybrid model integration
2. **`data/`**: Contains the dataset used for training and evaluation.
3. **`results/`**: Includes performance metrics and model outputs.
4. **`README.md`**: This file.

---

## How to Run the Project
1. Clone the repository.
2. Install required libraries:
   ```bash
   pip install -r requirements.txt
   ```
3. Run the notebook to execute the hybrid recommender system pipeline.

---

## Acknowledgments
- **References**:
  - Guo, G. (2012). Challenges in recommender systems.
  - Roy, A., & Dutta, S. (2022). Enhancing content-based recommendations.
  - Casalegno, F. (2022). Hybrid recommender systems: A review.  
