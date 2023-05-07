import json
import sys
import matplotlib.pyplot as plt

# Load data from JSON file
# read filename from argv

print(sys.argv)

with open(sys.argv[1], 'r') as f:
    data = json.load(f)

# Extract data for line chart
x = range(1, len(data['control_result']) + 1)
y1 = data['control_result']
y2 = data['experiment_result']

# Create line chart
plt.plot(x, y1, label='control')
plt.plot(x, y2, label='experiment')
plt.xlabel('iteration')
plt.ylabel('exec seconds')
plt.title('')
plt.legend()
plt.show()
