import requests
import json

TOKEN = ''

# Sends a friend request to the specified user
def send_friend_request(username, discriminator):
    headers = {
        'Authorization': f'Bot {TOKEN}',
        'Content-Type': 'application/json'
    }
    data = {
        'username': username,
        'discriminator': discriminator
    }
    response = requests.post('', headers=headers, data=json.dumps(data))
    return response.status_code == 200

# Sends a file to the specified friend
def send_file_to_friend(friend_id, file_path):
    headers = {
        'Authorization': f'Bot {TOKEN}'
    }
    with open(file_path, 'rb') as f:
        files = {'file': f}
        response = requests.post(f'', headers=headers, files=files)
        print(response.status_code)
        return response.status_code == 200

# Example usage
if send_friend_request('', ''):
    print('Friend request sent!')
else:
    print('Failed to send friend request.')

# Replace with the ID of the friend you want to send the file to
friend_id = ''

if send_file_to_friend(friend_id, ''):
    print('File sent successfully!')
else:
    print('Failed to send file.')

