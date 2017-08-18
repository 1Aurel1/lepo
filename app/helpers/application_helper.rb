# 0. for general
# 1. for html id / class
# 2. for text
# 3. for card
# 4. for others

module ApplicationHelper
  # 0. for general ============================================================================
  def add_br(txt)
    txt = html_escape(txt)
    txt.gsub(/\r\n|\r|\n/, '<br />')
  end

  def average(value, data_num, decimal_num)
    return if data_num.zero?
    (value.to_f / data_num).round(decimal_num)
  end

  def div_str(str)
    sanitize(str, tags: ['div'], attributes: %w[id class])
  end

  def get_summary(txt)
    double_return_index = txt.index('<br /><br />')
    if double_return_index
      summary = txt[0..(double_return_index - 1)]
      rest = txt[(double_return_index + 12)..txt.size]
      return [summary, rest]
    end
    [txt]
  end

  def get_short_string(original_string, max_length)
    original_string_array = original_string.split(//u)
    return original_string_array[0..(max_length - 2)].join + '..' if original_string_array.size > max_length
    original_string
  end

  def ratio(value1, value2, decimal_num)
    return if value2.zero?
    ((value1 * 100).to_f / value2.to_f).round(decimal_num)
  end

  def system_url
    protocol = SSL_ACCESS ? 'https://' : 'http://'
    return protocol + request.host_with_port + Rails.application.config.relative_url_root if Rails.application.config.relative_url_root
    protocol + request.host_with_port
  end

  # 1. for html id / class  ===================================================================
  def selected_id(identical)
    identical ? 'selected' : ''
  end

  def template_btn_class(content_id, objective_id)
    return 'btn btn-sm btn-success' if content_id.zero?
    return 'btn btn-sm btn-warning' if objective_id > 0
    'btn btn-sm btn-secondary'
  end

  def demerit_class(achievement, allocation)
    achievement < allocation ? 'demerit' : ''
  end

  def dropdown_position(text, left_max_size)
    text.size <= left_max_size ? '' : 'pull-right'
  end

  def required_class(required)
    required ? 'required' : 'optional'
  end

  # 2. for text ===============================================================================
  def display_title(obj)
    obj.title.size.nonzero? ? obj.title : t('views.no_title')
  end

  def format_time(t, category)
    case category
    when 'ymdhm'
      t.strftime('%Y年%-m月%-d日%H:%M')
    when 'ymd'
      t.strftime('%Y年%-m月%-d日')
    when 'mdhm'
      t.strftime('%-m月%-d日%H:%M')
    when 'mdh'
      t.strftime('%-m月%-d日%H時')
    when 'md'
      t.strftime('%-m月%-d日')
    end
  end

  def assignment_category_text(category)
    case category
    when 'text'
      '文章記述'
    when 'file'
      'ファイル提出'
    when 'outside'
      'システム外'
    end
  end

  def content_category_text(category)
    case category
    when 'home'
      'サポート'
    when 'repository'
      '管理している教材'
    end
  end

  def course_manager_text(managers)
    manager_num = managers.size
    case manager_num
    when 1
      return User.find(managers[0]).fullname
    else
      return User.find(managers[0]).familyname + ', 他' + (manager_num - 1).to_s + '名'
    end
  end

  def last_signin_at_text(date_at)
    return 'LePo未利用' unless date_at
    format_time date_at, 'ymdhm'
  end

  def member_role_text(model_category, member_role)
    return if member_role.empty?
    case model_category
    when 'content'
      t("activerecord.others.content_member.role.#{member_role}")
    when 'course'
      t('activerecord.attributes.course.' + member_role + 's')
    when 'system'
      t('activerecord.others.user.role.' + member_role)
    end
  end

  def outcome_message_text(evaluator_id)
    case evaluator_id
    when 0
      'コメント'
    else
      'メッセージ'
    end
  end

  def outcome_num_text(past_messages_num)
    submit_num = ((past_messages_num + 1) / 2)
    return '(' + submit_num.to_s + '回目の提出)' if submit_num > 0
    ''
  end

  def outcome_score_text(evaluator_id, score)
    case evaluator_id
    when 0
      '目標達成率 ' + (score * 10).to_s + '%'
    else
      '得点 ' + score.to_s + '点'
    end
  end

  def outcome_status_icon(outcome_status, score)
    case outcome_status
    when 'draft', 'self_submit', 'return'
      'fa fa-check' if score && score > 0
    when 'submit'
      'fa fa-comment'
    end
  end

  def outcome_status_text(outcome_status, score)
    case outcome_status
    when 'draft'
      return '修正中' if score && score > 0
      '未提出'
    when 'submit'
      '評価依頼中'
    when 'self_submit'
      '自己評価完了'
    when 'return'
      '評価完了'
    end
  end

  def outcome_submit_text(evaluator_id, role)
    case role
    when 'learner'
      case evaluator_id
      when 0
        '自己評価を保存'
      else
        '課題を提出'
      end
    when 'evaluator'
      case evaluator_id
      when 0
        'メッセージを送信'
      else
        '評価を確定'
      end
    when 'manager'
      'メッセージを送信'
    end
  end

  def lesson_evaluation_text(evaluator_id)
    return '' unless evaluator_id
    return t('views.content.self_evaluation') if evaluator_id.zero?
    return t('views.content.teacher_evaluation')
  end

  def lesson_evaluator_text(evaluator_id)
    return '' unless evaluator_id
    return t('views.content.self_evaluation') if evaluator_id.zero?
    t('views.content.evaluator') + ' ：' + User.find(evaluator_id).fullname
  end

  def page_num_text(page_num, max_page_num)
    case page_num
    when 0 then
      t('views.content.cover_page')
    when max_page_num then
      t('views.content.assignment_page')
    else
      'P.' + page_num.to_s
    end
  end

  def page_num_by_id_text(content, page_file_id)
    page_num = page_num_by_id(content, page_file_id)
    case page_num
    when 0
      return '表紙ページ'
    when content.page_files.size + 1
      return '課題ページ'
    else
      return page_num.to_s + 'ページ'
    end
  end

  def page_num_by_id(content, page_file_id)
    case page_file_id
    when 0
      0
    when -1
      content.page_files.size + 1
    else
      pages = content.page_files
      pages.each_with_index do |page, i|
        return (i + 1) if page.id == page_file_id
      end
    end
  end

  def score_text(score, with_unit)
    return with_unit ? (score.to_s + '点') : score.to_s if score
    '未評価'
  end

  def note_snippet_text(manager_flag, stickies)
    title = 'ふせんの数[枚]'
    if manager_flag
      title += ': '
      stickies.each_with_index do |st, i|
        title += User.fullname_for_id(st.manager_id)
        title += ', ' if i != (stickies.size - 1)
      end
    end
    title
  end

  def note_star_text(manager_flag, stared_users)
    title = 'スターの数[個]'
    if manager_flag
      title += ': '
      stared_users.each_with_index do |st, i|
        title += User.fullname_for_id(st.id)
        title += ', ' if i != (stared_users.size - 1)
      end
    end
    title
  end

  def note_status_text(status)
    case status
    when 'course'
      '　公開：コースノート'
    when 'private'
      '非公開：個人ノート'
    when 'master_draft'
      '非公開：コースノートとして学生に配布'
    when 'master_review'
      '　公開：コースノートを学生間で相互評価'
    when 'master_open'
      '　公開：コースノートを学生間で公開'
    end
  end

  def preference_icon(controller_name, action_name)
    case controller_name
    when 'courses'
      'fa-flag'
    when 'devices'
      # FIXME: PushNotification
      'fa-mobile'
    when 'links'
      'fa-link'
    when 'preferences'
      case action_name
      when 'ajax_account_pref'
        'fa-key'
      when 'ajax_new_user_pref'
        'fa-user-plus'
      when 'ajax_notice_pref'
        'fa-bullhorn'
      when 'ajax_profile_pref'
        'fa-user'
      when 'ajax_default_note_pref'
        'fa-file-text'
      when 'ajax_user_account_pref'
        'fa-users'
      end
    when 'terms'
      'fa-building'
    end
  end

  def resource_text(resource)
    case resource
    when 'contents'
      '教材'
    when 'courses'
      'コース'
    when 'course_members'
      'メンバー'
    when 'lessons'
      'レッスン'
    when 'snippets'
      '切り抜き'
    when 'stickies'
      'ふせん'
    when 'notes'
      'ノート'
    when 'users'
      '利用者'
    when 'system'
      'システム'
    end
  end

  def sticky_category_short_text(category)
    case category
    when 'course'
      'コース'
    when 'private'
      '個人'
    end
  end

  def sticky_category_text(category)
    case category
    when 'course', 'private'
      return sticky_category_short_text(category) + 'ふせん'
    when 'user'
      'ユーザのコースふせん'
    end
  end

  def status_text(status)
    case status
    when 'draft'
      '準備中'
    when 'open'
      '公開中'
    when 'archived'
      'アーカイブ'
    end
  end

  def status_explanation_text(status)
    case status
    when 'draft'
      'コース管理者とアシスタントのみ、保管庫からコースを閲覧可'
    when 'open'
      'コースの全員が、コースを閲覧可'
    when 'archived'
      'コースの全員が、保管庫からコースを閲覧可・活動は不可'
    end
  end

  # 3. for card ===============================================================================
  def content_activity_card_hash(user)
    managing_contents = Content.associated_by @user.id, 'manager'
    assisting_contents = Content.associated_by @user.id, 'assistant'
    card = {}
    card['icon'] = 'fa fa-book'
    card['header'] = '教材に関する活動'
    card['body'] = "管理している教材： #{managing_contents.size}教材\n"
    card['body'] += "補助している教材： #{assisting_contents.size}教材\n"
    card['summary'] = false
    card['footnotes'] = ['最終利用： ' + last_signin_at_text(user.last_signin_at)]
    card
  end

  def course_activity_card_hash(user)
    learning_courses = Course.associated_by @user.id, 'learner'
    managing_courses = Course.associated_by @user.id, 'manager'
    assisting_courses = Course.associated_by @user.id, 'assistant'
    card = {}
    card['icon'] = 'fa fa-flag'
    card['header'] = 'コースに関する活動'
    card['body'] = "学習しているコース： #{learning_courses.size}コース\n"
    card['body'] += "管理しているコース： #{managing_courses.size}コース\n"
    card['body'] += "補助しているコース： #{assisting_courses.size}コース\n"
    card['summary'] = false
    card['footnotes'] = ['最終利用： ' + last_signin_at_text(user.last_signin_at)]
    card['footnotes'].push("[#{t('views.content.manage')}: #{user.content_manageable? ? t('views.possible') : t('views.impossible')}]")
    card
  end

  def course_card_hash(course)
    card = {}
    if course.image?
      card['image'] = course.image.url(:px80)
    else
      card['icon'] = 'fa fa-flag'
    end
    # card['caption'] = ''
    card['header'] = course.title
    card['body'] = course.overview
    card['summary'] = true
    card['footnotes'] = [t('activerecord.models.term') + ' : ' + course.term.title]
    card
  end

  def lesson_activity_card_hash(course_role, lesson_resources)
    card = {}
    card['header'] = t('views.lesson_status')
    case course_role
    when 'learner'
      non_self_eval_num = lesson_resources['non_self_eval'].size
      if non_self_eval_num.zero?
        card['icon'] = 'fa fa-check-circle'
        card['body'] = '全ての公開レッスンで、自己評価済みです'
      else
        card['icon'] = 'fa fa-exclamation-circle'
        card['body'] = "以下のレッスンで、自己評価がされていません\n"
        lesson_resources['non_self_eval'].each_with_index do |lesson, i|
          card['body'] += "　・レッスン#{lesson.display_order}: #{lesson.content.title} \n"
          card['body'] += "\n" if (i == 1) && non_self_eval_num > 2
        end
      end
      card['summary'] = true
    else
      card['icon'] = 'fa fa-info-circle'
      card['body'] = '学生には、自己評価をしていないレッスンが表示されます'
      card['summary'] = false
    end
    card['footnotes'] = []
    card
  end

  def notice_card_hash(notice, border_category, course = Course.new)
    card = {}
    if notice.manager.image?
      card['image'] = notice.manager.image.url(:px80)
    else
      card['icon'] = 'fa fa-user'
    end
    card['caption'] = notice.manager.fullname
    card['body'] = notice.message
    card['footnotes'] = [format_time(notice.updated_at, 'ymdhm')]
    card['footnotes'].push('[更新]') if notice.created_at != notice.updated_at

    case action_name
    when 'ajax_edit_notice', 'ajax_notice_pref', 'ajax_create_notice', 'ajax_destroy_notice', 'ajax_reedit_notice', 'ajax_archive_notice', 'ajax_open_notice', 'ajax_update_notice'
      course_id = course.new_record? ? 0 : course.id
      card['operations'] = notice_card_operations(notice, border_category, course_id)
    when 'signin'
      card['operations'] = nil
    else
      card['operations'] = [{ label: '公開終了', url: { action: 'ajax_archive_notice_from_course_top', id: course.id, notice_id: notice.id } }] if course.staff? session[:id]
    end
    card
  end

  def notice_card_operations(notice, border_category, course_id)
    operations = []
    case border_category
    when 'course'
      operations.push(label: '公開終了', url: { action: 'ajax_archive_notice', id: course_id, notice_id: notice.id })
      if notice.manager_id == session[:id]
        operations.push(label: t('views.edit'), url: { action: 'ajax_reedit_notice', id: course_id, notice_id: notice.id })
      end
    when 'pending'
      if notice.manager_id == session[:id]
        operations.push(label: '削除', url: { action: 'ajax_destroy_notice', id: course_id, notice_id: notice.id })
      end
      operations.push(label: '再掲示', url: { action: 'ajax_open_notice', id: course_id, notice_id: notice.id })
    end
    operations
  end

  def sticky_activity_card_hash(user, stickies)
    card = {}
    card['icon'] = 'fa fa-th-list fa-flip-horizontal'
    card['header'] = 'ふせんに関する活動'
    card['body'] = "個人ふせん： 計#{stickies['private']}枚\n"
    card['body'] += "コースふせん： 計#{stickies['course']}枚\n"
    card['summary'] = false
    card['footnotes'] = ['最終利用： ' + last_signin_at_text(user.last_signin_at)]
    card
  end

  def support_card_hash(category)
    card = {}
    case category
    when 'content'
      card['icon'] = 'fa fa-book'
      card['header'] = '教材とは？'
      card['body'] = 'PC等で作成した教材ファイルをLePoにアップロードして、教材として利用できます。教材には学習目標と課題の設定が必須です。また、学生は教材の学習目標に対して自己評価を行うことが必須です。教材は以下の手順で新規作成することができます。'
    when 'selfeval_chart'
      card['icon'] = 'fa fa-info-circle'
      card['header'] = '自己評価の推移'
      card['body'] = '学生には、自己評価合計の2週間の推移が表示されます。'
    end
    card['summary'] = false
    card['footnotes'] = []
    card
  end

  def user_card_l_hash(user)
    card = {}
    if user.image?
      card['image'] = user.image.url(:px80)
    else
      card['icon'] = 'fa fa-user'
    end
    card['header'] = link_to_if(user.web_url?, user.fullname + ' [' + user.fullname_alt + ']', user.web_url, target: '_blank')
    card['body'] = user.description
    card['summary'] = false
    if user.updated_at
      card['footnotes'] = ['最終更新： ' + format_time(user.updated_at, 'ymdhm')]
    else
      card['footnotes'] = ['最終更新： 未更新']
    end
    card
  end

  def user_card_l_border(user)
    return 'course' if session[:nav_controller] != 'course_members'
    course = Course.find(session[:nav_id])
    return 'staff' if course.staff? user.id
    'learner'
  end

  def member_candidate_url(category, form_category, user, resource_id, update_to, search_word, member_role, candidates_csv)
    case category
    when 'content'
      { action: 'ajax_update_role', user_id: user.id, content_id: resource_id, update_to: update_to, form_category: form_category, search_word: search_word, member_role: member_role, candidates_csv: candidates_csv }
    when 'course'
      { action: 'ajax_update_role', user_id: user.id, course_id: resource_id, update_to: update_to, form_category: form_category, search_word: search_word, member_role: member_role, candidates_csv: candidates_csv }
    when 'system'
      if update_to == 'suspended'
        { action: 'ajax_update_role', user_id: user.id, update_to: 'suspended', form_category: form_category, search_word: search_word, member_role: member_role, candidates_csv: candidates_csv }
      else
        params = { role: user.role, authentication: user.authentication, user_id: user.user_id, password: user.password, familyname: user.familyname, givenname: user.givenname, familyname_alt: user.familyname_alt, givenname_alt: user.givenname_alt, candidates_csv: candidates_csv }
        { action: 'ajax_create_user' }.merge params
      end
    end
  end

  def managers_of_course(category, user, course_id, manager_ids)
      { controller: 'course_members', action: 'ajax_get_managers', category: category, manager_id: user.id, course_id: course_id, manager_ids: manager_ids}
  end

  # 4. for others =============================================================================
  def available_links
    user_id = session[:id]
    return Link.by_user(user_id) + Link.by_system_staffs if user_id && !User.system_staff?(user_id)
    Link.by_system_staffs
  end

  def check_identical(item, nav_id_exists, nav_section, nav_controller, nav_id)
    return false if (item[:nav_section] != nav_section) || (item[:nav_controller] != nav_controller)
    return (item[:nav_id] == nav_id.to_i) if nav_id_exists
    true
  end

  def course_cancel_hash
    case session[:nav_id]
    when 0
      # for new course creation
      { controller: 'preferences', action: 'ajax_index', nav_section: 'home', nav_id: 0 }
    else
      # for existing course edit
      { controller: 'courses', action: 'ajax_index', nav_section: session[:nav_section], nav_id: session[:nav_id] }
    end
  end

  def get_assignment_categories
    [[assignment_category_text('outside'), 'outside'], [assignment_category_text('text'), 'text'], [assignment_category_text('file'), 'file']]
  end

  def note_courses
    note_courses = [['なし（コースに未保存）', 0]]
    open_courses = Course.open_with session[:id]
    open_courses.each do |course|
      note_courses.push([course.title, course.id])
    end
    note_courses
  end

  def note_statuses(note)
    case note.status
    when 'private', 'course'
      return [[note_status_text('private'), 'private'], [note_status_text('master_draft'), 'master_draft'], [note_status_text('course'), 'course']]
    when 'master_draft', 'master_review', 'master_open'
      course = Course.find(note.course_id)
      review_notes = course.master_review_notes
      if review_notes.size.zero? || (review_notes.include? note)
        return [[note_status_text('master_draft'), 'master_draft'], [note_status_text('master_review'), 'master_review'], [note_status_text('master_open'), 'master_open']]
      else
        return [[note_status_text('master_draft'), 'master_draft'], [note_status_text('master_open'), 'master_open']]
      end

    end
  end

  def get_evaluators(managers)
    evaluators = [[lesson_evaluator_text(0), 0]]
    managers.each do |manager|
      evaluators.push [lesson_evaluator_text(manager.id), manager.id]
    end
    evaluators
  end

  def main_nav_items(section, subsections = [])
    items = []
    case section
    when 'home'
      items.push(nav_section: 'home', nav_controller: 'dashboard', title: t('views.navs.dashboard'), class: 'fa fa-dashboard fa-lg')
      items.push(nav_section: 'home', nav_controller: 'snippets', title: t('views.navs.note_management'), class: 'fa fa-file-text fa-lg')
      items.push(nav_section: 'home', nav_controller: 'contents', title: t('views.navs.support'), class: 'fa fa-question-circle fa-lg')
      items.push(nav_section: 'home', nav_controller: 'preferences', title: t('views.navs.preferences'), class: 'fa fa-cog fa-lg')
    when 'open_courses'
      subsections.each do |course|
        items.push(nav_section: 'open_courses', nav_controller: 'courses', nav_id: course.id, title: course.title, class: 'fa fa-flag fa-lg')
        items.push(nav_section: 'open_courses', nav_controller: 'portfolios', nav_id: course.id, title: t('views.navs.portfolio'), class: 'no-icon')
        # items.push(nav_section: 'open_courses', nav_controller: 'stickies', nav_id: course.id, title: t('activerecord.models.sticky'), class: 'no-icon')
        items.push(nav_section: 'open_courses', nav_controller: 'notes', nav_id: course.id, title: t('activerecord.models.note'), class: 'no-icon')
        items.push(nav_section: 'open_courses', nav_controller: 'course_members', nav_id: course.id, title: t('activerecord.models.course_member'), class: 'no-icon')
      end
    when 'repository'
      items.push(nav_section: 'repository', nav_controller: 'contents', title: t('activerecord.models.content'), class: 'fa fa-book fa-lg')
      subsections.each do |course|
        items.push(nav_section: 'repository', nav_controller: 'courses', nav_id: course.id, title: course.title, class: 'fa fa-flag fa-lg')
        items.push(nav_section: 'repository', nav_controller: 'portfolios', nav_id: course.id, title: t('views.navs.portfolio'), class: 'no-icon')
        items.push(nav_section: 'repository', nav_controller: 'notes', nav_id: course.id, title: t('activerecord.models.note'), class: 'no-icon')
        items.push(nav_section: 'repository', nav_controller: 'course_members', nav_id: course.id, title: t('activerecord.models.course_member'), class: 'no-icon')
      end
    end
    items
  end

  def get_selected_association(_lesson_id, objective_id, associations)
    associations.each do |a|
      return a if a.objective_id == objective_id
    end
    GoalsObjective.new(goal_id: 0)
  end

  def get_self_achievement_charts(user_id, course_id, latest, interval, data_num)
    line_data = '['
    x_min = ''
    x_max = ''
    y_max = 0

    data_num.times do |data|
      day = latest - (data_num - data - 1) * interval
      outcome_messages = OutcomeMessage.where('manager_id = ? AND created_at < ?', user_id, day + 1).group(:outcome_id)
      achievement = 0
      outcome_messages.each do |om|
        achievement += om.score if om.score && (om.outcome.lesson.course.id == course_id) && (om.outcome.lesson.status == 'open')
      end
      line_data += "['" + day.strftime('%Y-%m-%d') + "', #{achievement}],"
      x_min = day.strftime('%b %d, %Y') if data.zero?
      x_max = day.strftime('%b %d, %Y')
      y_max = achievement
    end

    line_data = line_data.slice(0, line_data.length - 1) if line_data.length > 1
    line_data += ']'

    { 'chart_id' => 'self-eval-chart', title: '自己評価合計の推移（過去2週間）', 'x_title' => '', 'x_min' => x_min, 'x_max' => x_max, 'y_title' => '点', 'y_max' => y_max, 'line_data' => line_data }
  end

  def get_url_hash(course_id, _course_status)
    { controller: 'courses', action: 'ajax_index', nav_section: session[:nav_section], nav_id: course_id }
  end

  def link_to_lesson(body, course_id, lesson_id, html_options)
    link_to(sanitize("<div>#{body}</div>"), { controller: 'courses', action: 'ajax_show', id: course_id, lesson_id: lesson_id }, html_options.merge(remote: true))
  end

  def link_to_lesson_evaluator(course, lesson)
    title = lesson_evaluator_text lesson.evaluator_id
    outcomes = lesson.outcomes
    if outcomes
      non_draft_outcomes = outcomes.reject { |x| x.status == 'draft' }
      if non_draft_outcomes && !non_draft_outcomes.empty?
        return title if lesson.evaluator_id.zero? || (course.managers.size == 1)
      end
    end
    link_to(title, { action: 'ajax_update_evaluator_from', id: course.id, lesson_id: lesson.id }, class: 'bright-link', remote: true)
  end

  def link_to_target_in_course(sticky, grouped_by_content)
    case sticky.target_type
    when 'page'
      page_num_text = page_num_by_id_text sticky.content, sticky.target_id
      sticky_title = page_num_text
      sticky_title = sticky.content.title + ': ' + sticky_title unless grouped_by_content
      course_id_for_link = sticky.course_id_for_link
      if course_id_for_link > 0
        link_to(sticky_title, { controller: 'courses', action: 'ajax_show_page_from_sticky', course_id: course_id_for_link, content_id: sticky.content.id, target_id: sticky.target_id }, title: '教材に移動', remote: true)
      else
        sticky_title
      end
    when 'note'
      note = Note.find(sticky.target_id)
      sticky_title = note.title + ' by ' + note.manager.fullname

      course_id_for_link = sticky.course_id_for_link
      if course_id_for_link > 0
        link_to(sticky_title, { controller: 'notes', action: 'ajax_show_from_others', nav_id: course_id_for_link, id: sticky.target_id }, title: 'ノートに移動', remote: true)
      else
        sticky_title
      end
    end
  end

  def link_to_resource(body, resource_id, html_options, action = 'ajax_show')
    link_to(sanitize("<div>#{body}</div>"), { action: action, id: resource_id }, html_options.merge(remote: true))
  end

  def marked_resource_num(marked_resources)
    marked_num = 0
    marked_resources.each do |_key, value|
      marked_num += value.to_i
    end
    marked_num
  end

  def member_role_options(update_model)
    case update_model
    when 'content_member'
      options = [[t('activerecord.others.content_member.role.manager') + t('views.candidate'), 'manager']]
      options.push [t('activerecord.others.content_member.role.assistant') + t('views.candidate'), 'assistant']
      options.push [t('activerecord.others.content_member.role.user') + t('views.candidate'), 'user']
    when 'course_member'
      options = [[t('activerecord.attributes.course.managers') + t('views.candidate'), 'manager']]
      options.push [t('activerecord.attributes.course.assistants') + t('views.candidate'), 'assistant']
      options.push [t('activerecord.attributes.course.learners') + t('views.candidate'), 'learner']
    when 'system'
      options = [[t('activerecord.others.user.role.admin'), 'admin']]
      options.push [t('activerecord.others.user.role.manager'), 'manager']
      options.push [t('activerecord.others.user.role.user'), 'user']
      options.push [t('activerecord.others.user.role.suspended'), 'suspended']
    end
    options
  end

  def page_exists?(page_num, max_page_num)
    # page 0 is cover page and page max_page_num is assignment page
    ((page_num >= 0) && (page_num <= max_page_num))
  end

  def previous_status_button(evaluator_id, lesson_role, outcome)
    case lesson_role
    when 'learner'
      case outcome.status
      when 'draft'
        if evaluator_id > 0
          link_to(raw("<i class = 'fa fa-times-circle fa-lg'></i> 再提出をキャンセル"), { controller: 'outcomes', action: 'ajax_previous_status', id: outcome.id, previous_status: 'return' }, class: 'btn btn-secondary', remote: true) if outcome.score
        else
          link_to(raw("<i class = 'fa fa-times-circle fa-lg'></i> 再自己評価をキャンセル"), { controller: 'outcomes', action: 'ajax_previous_status', id: outcome.id, previous_status: 'self_submit' }, class: 'btn btn-secondary', remote: true) if outcome.score
        end
      when 'self_submit'
        link_to(raw("<i class = 'fa fa-check-circle fa-lg'></i> 自己評価を再入力"), { controller: 'outcomes', action: 'ajax_previous_status', id: outcome.id, previous_status: 'draft' }, class: 'btn btn-secondary', remote: true)
      when 'submit'
        if outcome.checked
          '教師が評価中のため、評価依頼をキャンセルできません'
        else
          link_to(raw("<i class = 'fa fa-times-circle fa-lg'></i> 評価依頼をキャンセル"), { controller: 'outcomes', action: 'ajax_previous_status', id: outcome.id, previous_status: 'draft' }, class: 'btn btn-secondary', remote: true)
        end
      when 'return'
        link_to(raw("<i class = 'fa fa-check-circle fa-lg'></i> 課題を再提出"), { controller: 'outcomes', action: 'ajax_previous_status', id: outcome.id, previous_status: 'draft' }, class: 'btn btn-secondary', remote: true)
      end
    when 'evaluator'
      case outcome.status
      when 'return'
        link_to(raw("<i class = 'fa fa-times-circle fa-lg'></i> 評価をキャンセル"), { controller: 'outcomes', action: 'ajax_previous_status', id: outcome.id, previous_status: 'submit' }, class: 'btn btn-secondary', remote: true)
      end
    end
  end

  def user_stared_sticky?(user_id, sticky)
    case sticky.category
    when 'private'
      (sticky.stars_count == 1)
    else
      sticky_star = StickyStar.find_by_manager_id_and_sticky_id(user_id, sticky.id)
      sticky_star && sticky_star.stared
    end
  end

  def user_stared_note?(user_id, note)
    note_star = NoteStar.find_by_manager_id_and_note_id(user_id, note.id)
    note_star && note_star.stared
  end

  def sticky_star_btn_class(user_id, sticky)
    stared = user_stared_sticky? user_id, sticky
    stared ? 'stared' : ''
  end

  def note_star_btn_class(user_id, note)
    stared = user_stared_note? user_id, note
    stared ? 'stared' : ''
  end
end
