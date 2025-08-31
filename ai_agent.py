from flask import Flask, request, jsonify
import requests
from bs4 import BeautifulSoup

app = Flask(__name__)

def search_internet(query):
    """使用 Google 搜尋資訊。"""
    url = f"https://www.google.com/search?q={query}"
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36"
    }
    response = requests.get(url, headers=headers)
    response.raise_for_status()  # 檢查是否有錯誤

    soup = BeautifulSoup(response.text, "html.parser")
    
    # Google 的 class 名稱經常變動，這裡使用一個比較通用的選擇器
    # 我們尋找包含連結 (<a>) 和標題 (<h3>) 的區塊
    results = soup.find_all("div", class_="g") 

    search_results = []
    for result in results:
        link_tag = result.find("a")
        title_tag = result.find("h3")
        
        if link_tag and title_tag:
            link = link_tag.get("href")
            title = title_tag.text
            # 過濾掉非搜尋結果的連結
            if link and link.startswith("http"):
                search_results.append({"title": title, "link": link})
    
    return search_results[:5] # 返回前 5 個結果

@app.route('/ask', methods=['POST'])
def ask():
    """接收問題並返回答案。"""
    data = request.get_json()
    if not data or 'query' not in data:
        return jsonify({"error": "Missing 'query' in request body"}), 400
        
    query = data['query']

    try:
        results = search_internet(query)
        return jsonify({"results": results})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
