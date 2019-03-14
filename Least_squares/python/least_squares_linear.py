import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.metrics import mean_squared_error, r2_score

plt.rcParams['figure.figsize'] = (10.0, 8.0)

def collect_data():
    data = pd.read_csv('data.csv')
    X = data.iloc[:, 0]
    Y = data.iloc[:, 1]
    return X, Y

def quadratic_loss(predict, data_y):

    loss = 0

    for i in range(len(data_y)):
        loss += (data_y[i] - predict[i])**2

    return loss    

def rmse(predict, data_y):
    return np.sqrt(quadratic_loss(predict, data_y)/len(predict)) 

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

def least_squares_grad(data_x, data_y, lr, iters, m = 0, c = 0):

    N = len(data_x)

    m_current = m
    c_current = c

    for i in range(iters):
        y_current = (m_current * data_x) + c_current
        m_gradient = -(2/N) * sum(data_x * (data_y - y_current))
        c_gradient = -(2/N) * sum(data_y - y_current)
        m_current = m_current - (lr * m_gradient)
        c_current = c_current - (lr * c_gradient)

    return m_current, c_current    

if __name__ == "__main__":

    x = []
    y = []

    x, y = collect_data()
    plt.scatter(x,y)

    m, c = least_squares(x, y)

    pred = m*x + c

    plt.plot(x, pred, color = 'red')

    print("Loss: ", float(quadratic_loss(pred, y)))
    print("RMSE: ", float(rmse(pred, y)))

    m_grad, c_grad = least_squares_grad(x, y, 0.0001, 1000)

    pred_grad = m_grad*x + c_grad

    plt.plot(x, pred_grad, color = 'green')

    plt.title('Loss LS_LR: {} \n RMSE LS_LR: {} \n Loss GLS_LR: {} \n RMSE GLS_LR: {}'\
        .format(float(quadratic_loss(pred, y)), float(rmse(pred, y)), float(quadratic_loss(pred_grad, y)), float(rmse(pred_grad, y))))

    plt.show()

    print("Loss: ", float(quadratic_loss(pred, y)))
    print("RMSE: ", float(rmse(pred, y)))
