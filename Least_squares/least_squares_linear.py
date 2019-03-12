import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
plt.rcParams['figure.figsize'] = (10.0, 8.0)

def collect_data():
    from sklearn import datasets, linear_model
    diabetes = datasets.load_diabetes()
    bmi_data_x = diabetes.data[:, np.newaxis, 2]
    desease_y = diabetes.target[:]

    # positive shift data
    # x_min = np.min(bmi_data_x)
    # bmi_data_x = bmi_data_x + (x_min * -1)

    return bmi_data_x, desease_y

def quadratic_loss(predict, data_y):

    loss = 0

    for i in range(len(data_y)):
        loss += (data_y[i] - predict[i])**2

    return loss    

def least_squares(data_x, data_y):

    mean_x = np.mean(data_x)
    mean_y = np.mean(data_y)

    m_num = 0
    m_den = 0

    n = len(data_x)

    for i in range(n):
        m_num += (data_x[i] - mean_x)*(data_y[i] - mean_y)
        m_den += (data_x[i] - mean_x)**2

    m = m_num / m_den
    c = mean_y - m*mean_x

    return m, c    

if __name__ == "__main__":

    x = []
    y = []

    x, y = collect_data()
    plt.scatter(x,y)

    m, c = least_squares(x, y)

    pred = m*x + c

    plt.plot(x, pred, color = 'red')
    plt.show()

    print(quadratic_loss(pred, y))
