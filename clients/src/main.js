// encoding: utf-8

let Vue = require('vue');
Vue.use(require('vue-dnd'));

class EditApp extends Vue {
    constructor(element) {
        var properties = {
            el: element,
            data: {
                summaryID: null,
                title: '',
                description: '',
                messages: [],

                loadMessages: [],
                nowLoading: false,
                nowSubmitting: false
            },
            ready() {
                const assignElement = $(this.$el).find('.js-assign-data');
                this.summaryID = assignElement.data('summary-id');
                this.title = assignElement.data('title');
                this.description = assignElement.data('description');
                this.messages = assignElement.data('messages');
            },
            methods: {
                sortMessage: (messages, loadMessages, index, droptag, dropdata) => {
                    switch (dropdata.type) {
                        case 'message':
                            let t = messages[index]
                            messages[index] = messages[dropdata.index]
                            messages.splice(dropdata.index, 1, t)
                            break
                        case 'loadMessage':
                            messages.splice(index, 0, loadMessages[dropdata.index])
                            loadMessages.splice(dropdata.index, 1)
                            break
                    }
                },
                insertMessage: (messages, loadMessages, index, droptag, dropdata) => {
                    let t;
                    switch (dropdata.type) {
                        case 'message':
                            t = messages[dropdata.index]
                            if (dropdata.index < index) {
                                messages.splice(dropdata.index, 1)
                                messages.splice(index - 1, 0, t)
                            } else {
                                messages.splice(dropdata.index, 1)
                                messages.splice(index, 0, t)
                            }
                            break;
                        case 'loadMessage':
                            if (messages.length >= 1000) {
                                alert('これ以上追加できません')
                                return
                            }
                            t = loadMessages[dropdata.index]
                            loadMessages.splice(dropdata.index, 1)
                            messages.splice(index, 0, t)
                            break;
                    }
                },
                addMessage: (messages, loadMessages, droptag, dropdata) => {
                    switch (dropdata.type) {
                        case 'message':
                            let t = messages[dropdata.index];
                            messages.push(t)
                            messages.splice(dropdata.index, 1)
                            break
                        case 'loadMessage':
                            if (messages.length >= 1000) {
                                alert('これ以上追加できません')
                                return
                            }
                            messages.push(loadMessages[dropdata.index])
                            loadMessages.splice(dropdata.index, 1)
                            break
                    }
                },
                dropMessage: (messages, droptag, dropdata) => {
                    if (dropdata.type != 'message') return
                    messages.splice(dropdata.index, 1)
                },
                onPermalink: (e, permalink, loadMessages) => {
                    e.preventDefault()
                    if (permalink && permalink.match(/^https:\/\//)) {
                        this.nowLoading = true
                        $.ajax({
                            type: 'get',
                            url: '/api/histories.json',
                            data: {url: permalink},
                            success: (resp) => {
                                this.nowLoading = false
                                loadMessages.splice(0, loadMessages.length)
                                for (let i = 0; i < resp.result.length; ++i) {
                                    loadMessages.push(resp.result[i])
                                }
                            },
                            error: (resp) => {
                                this.nowLoading = false
                                alert('取得できませんでした O_o')
                            }
                        })
                    }
                },
                onSubmit: (e, title, description, messages) => {
                    let messageIDs = messages.map((n) => {
                        return n.id
                    })
                    e.preventDefault()
                    if (messageIDs.length == 0) {
                        alert('まとめるメッセージを選択してください。')
                        return
                    }
                    if (`${title}`.length < 1 || `${title}`.length > 64) {
                        alert('タイトルを1〜64文字で入力してください。')
                        return
                    }
                    if (`${description}`.length > 1024) {
                        alert('説明文を1024文字以内で入力してください。')
                        return
                    }
                    this.nowSubmitting = true
                    $.ajax({
                        type: (this.summaryID ? 'put' : 'post'),
                        url: (this.summaryID ? `/summaries/${this.summaryID}.json` : '/summaries.json'),
                        data: {
                            authenticity_token: $('meta[name="csrf-token"]').val(),
                            title: title,
                            description: description,
                            messages: messageIDs
                        },
                        success: (data) => {
                            location.href = data.result.path
                        },
                        error: () => {
                            this.nowSubmitting = false
                            alert('投稿できませんでした')
                        }
                    })
                }
            }
        }
        super(properties)
    }
}

let createEditApp = (element) => {
    return new EditApp(element)
}

window.createEditApp = createEditApp
