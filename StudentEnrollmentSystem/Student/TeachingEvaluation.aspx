<%@ Page Title="Student Evaluation" Language="C#" MasterPageFile="~/Student.Master" AutoEventWireup="true" CodeBehind="TeachingEvaluation.aspx.cs" Inherits="StudentEnrollmentSystem.Student.TeachingEvaluation" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<style>
    .eval-wrap { display: flex; flex-direction: column; gap: 28px; }

    .page-header h2 { font-size: 28px; font-weight: 700; color: #0f172a; margin: 0 0 4px; }
    .page-header p  { font-size: 14px; color: #64748b; margin: 0; }

    .stats-row { display: grid; grid-template-columns: repeat(2,1fr); gap: 20px; }

    .stat-card {
        background: #fff; border-radius: 16px; padding: 22px 24px;
        border: 1px solid rgba(0,0,0,0.06);
        box-shadow: 0 4px 12px rgba(0,0,0,0.04);
        display: flex; align-items: center; justify-content: space-between;
        transition: box-shadow 0.2s, transform 0.2s;
    }

    .stat-card:hover { box-shadow: 0 10px 24px rgba(0,0,0,0.08); transform: translateY(-2px); }
    .stat-label { font-size: 13px; font-weight: 500; color: #64748b; }
    .stat-value { font-size: 32px; font-weight: 700; color: #0f172a; margin: 6px 0 0; line-height: 1; }

    .stat-icon  {
        width: 48px; height: 48px; border-radius: 12px;
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
        transition: transform 0.2s;
    }

    .stat-card:hover .stat-icon { transform: scale(1.1); }
    .stat-icon i { font-size: 20px; color: #fff; }
    .icon-slate  { background: linear-gradient(135deg,#64748b,#475569); box-shadow: 0 4px 10px rgba(100,116,139,0.3); }
    .icon-green  { background: linear-gradient(135deg,#10b981,#14b8a6); box-shadow: 0 4px 10px rgba(16,185,129,0.3); }

    .two-col { display: grid; grid-template-columns: 280px 1fr; gap: 28px; align-items: start; }

    .card {
        background: #fff; border-radius: 16px; padding: 28px;
        border: 1px solid rgba(0,0,0,0.06);
        box-shadow: 0 4px 12px rgba(0,0,0,0.04);
    }

    .card-title { font-size: 17px; font-weight: 700; color: #0f172a; margin: 0 0 20px; }

    .course-btn {
        display: block; width: 100%; text-align: left;
        padding: 14px; border-radius: 12px;
        border: 1px solid #e2e8f0; background: #fff;
        cursor: pointer; transition: all 0.2s; margin-bottom: 8px;
    }

    .course-btn:last-child { margin-bottom: 0; }
    .course-btn:hover:not(:disabled) { border-color: #c7d2fe; background: #fafbff; }
    .course-btn.selected { border-color: #6366f1; background: #eef2ff; }
    .course-btn:disabled { opacity: 0.55; cursor: not-allowed; background: #f8fafc; }
    .cb-top { display: flex; align-items: flex-start; justify-content: space-between; gap: 8px; }
    .cb-code { font-size: 14px; font-weight: 700; color: #0f172a; }
    .cb-name { font-size: 12px; color: #64748b; margin-top: 2px; }
    .cb-inst { font-size: 11px; color: #94a3b8; margin-top: 4px; }

    .form-group { margin-bottom: 24px; }
    .form-label { display: block; font-size: 13px; font-weight: 600; color: #374151; margin-bottom: 8px; }

    .form-select, .form-textarea {
        width: 100%; padding: 11px 14px;
        border: 1px solid #e2e8f0; border-radius: 12px;
        font-size: 14px; color: #0f172a; background: #f8fafc;
        outline: none; transition: border-color 0.2s, box-shadow 0.2s;
        box-sizing: border-box; font-family: inherit;
    }

    .form-select:focus, .form-textarea:focus {
        border-color: #6366f1;
        box-shadow: 0 0 0 3px rgba(99,102,241,0.12);
        background: #fff;
    }

    .form-textarea { resize: none; line-height: 1.6; }

    .star-group { margin-bottom: 24px; }
    .star-row { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; margin-top: 8px; }
    .star-label-text { font-size: 13px; font-weight: 600; color: #374151; margin-bottom: 0; }

    .star-btn {
        background: none; border: none; cursor: pointer; padding: 2px;
        font-size: 26px; color: #d1d5db; line-height: 1;
        transition: transform 0.1s, color 0.1s;
    }

    .star-btn:hover { transform: scale(1.2); }
    .star-btn.active { color: #fbbf24; }
    .star-val { font-size: 13px; color: #94a3b8; margin-left: 4px; }

    .hidden-ddl { display: none !important; }

    .anon-row {
        display: flex; align-items: center; gap: 10px;
        padding: 14px 16px; border-radius: 12px;
        border: 1px solid #e2e8f0; background: #f8fafc;
        margin-bottom: 24px; cursor: pointer;
    }

    .anon-row input { width: 18px; height: 18px; accent-color: #6366f1; cursor: pointer; }
    .anon-row label { font-size: 14px; font-weight: 500; color: #374151; cursor: pointer; }

    .btn-submit {
        display: inline-flex; align-items: center; gap: 8px;
        padding: 12px 28px; width: 100%; justify-content: center;
        background: linear-gradient(90deg,#6366f1,#9333ea);
        color: #fff; border: none; border-radius: 12px;
        font-size: 14px; font-weight: 600; cursor: pointer;
        box-shadow: 0 4px 14px rgba(99,102,241,0.3);
        transition: opacity 0.2s, box-shadow 0.2s;
    }

    .btn-submit:hover:not(:disabled) { opacity: 0.9; box-shadow: 0 8px 22px rgba(99,102,241,0.4); }
    .btn-submit:disabled { background: #e2e8f0; color: #94a3b8; box-shadow: none; cursor: not-allowed; }

    .semester-row { display: flex; align-items: center; gap: 12px; margin-bottom: 16px; }
    .semester-row .form-label { margin: 0; white-space: nowrap; }

    .msg-success {
        display: flex; align-items: center; gap: 10px;
        padding: 14px 18px; border-radius: 12px;
        background: #f0fdf4; border: 1px solid #bbf7d0;
        color: #15803d; font-size: 14px; font-weight: 600;
    }

    .msg-error {
        display: flex; align-items: center; gap: 10px;
        padding: 14px 18px; border-radius: 12px;
        background: #fef2f2; border: 1px solid #fecaca;
        color: #b91c1c; font-size: 14px; font-weight: 600;
    }

    .success-state {
        text-align: center; padding: 48px 24px;
    }

    .success-icon {
        width: 64px; height: 64px; border-radius: 50%;
        background: linear-gradient(135deg,#10b981,#14b8a6);
        display: flex; align-items: center; justify-content: center;
        margin: 0 auto 16px;
        box-shadow: 0 8px 20px rgba(16,185,129,0.3);
    }

    .success-icon i { font-size: 28px; color: #fff; }
    .success-title  { font-size: 20px; font-weight: 700; color: #0f172a; margin-bottom: 8px; }
    .success-sub    { font-size: 14px; color: #64748b; }

    .form-empty {
        text-align: center; padding: 48px 24px;
    }

    .form-empty-icon {
        width: 56px; height: 56px; border-radius: 50%;
        background: #f1f5f9;
        display: flex; align-items: center; justify-content: center;
        margin: 0 auto 14px;
    }

    .form-empty-icon i { font-size: 24px; color: #94a3b8; }
    .form-empty-title { font-size: 15px; font-weight: 600; color: #475569; margin-bottom: 4px; }
    .form-empty-sub   { font-size: 13px; color: #94a3b8; }

    .gv-eval { width: 100%; border-collapse: collapse; }
    .gv-eval thead tr { background: #f8fafc; border-bottom: 1px solid #e2e8f0; }

    .gv-eval th {
        padding: 11px 14px; text-align: left;
        font-size: 11px; font-weight: 700; color: #64748b;
        text-transform: uppercase; letter-spacing: 0.06em; white-space: nowrap;
    }

    .gv-eval td {
        padding: 14px; font-size: 14px; color: #334155;
        border-bottom: 1px solid #f1f5f9; vertical-align: middle;
    }

    .gv-eval tr:hover td { background: #fafbff; }

    .gv-eval .empty-row td {
        text-align: center; padding: 48px; color: #94a3b8; font-size: 14px;
    }

    .stars-display { color: #fbbf24; font-size: 14px; letter-spacing: 1px; }
    .stars-display .empty-star { color: #d1d5db; }

    .comment-cell {
        max-width: 220px; overflow: hidden;
        text-overflow: ellipsis; white-space: nowrap;
        color: #64748b; font-style: italic;
    }

    .badge-course { background: #f1f5f9; color: #475569; }

    .badge {
        display: inline-block; padding: 3px 10px;
        border-radius: 99px; font-size: 11px; font-weight: 600;
    }

    @media (max-width: 900px) {
        .two-col { grid-template-columns: 1fr; }
        .stats-row { grid-template-columns: 1fr; }
    }
</style>

<div class="eval-wrap">
    <div class="page-header">
        <h2>Student Evaluation of Teaching</h2>
        <p>Provide feedback on your courses and instructors</p>
    </div>

    <asp:Label ID="lblMsg" runat="server" />

    <div class="stats-row">
        <div class="stat-card">
            <div>
                <div class="stat-label">Pending Evaluations</div>
                <div class="stat-value">
                    <asp:Label ID="lblPending" runat="server" Text="0" />
                </div>
            </div>
            <div class="stat-icon icon-slate"><i class="fa fa-clock-o"></i></div>
        </div>
        <div class="stat-card">
            <div>
                <div class="stat-label">Completed Evaluations</div>
                <div class="stat-value">
                    <asp:Label ID="lblCompleted" runat="server" Text="0" />
                </div>
            </div>
            <div class="stat-icon icon-green"><i class="fa fa-check-circle"></i></div>
        </div>
    </div>

    <div class="card" style="padding: 20px 28px;">
        <div class="semester-row">
            <label class="form-label" for="<%= ddlSemester.ClientID %>">Semester:</label>
            <asp:DropDownList ID="ddlSemester" runat="server"
                CssClass="form-select" style="max-width:260px;"
                AutoPostBack="true"
                OnSelectedIndexChanged="ddlSemester_SelectedIndexChanged" />
        </div>
    </div>

    <div class="two-col">
        <div class="card">
            <div class="card-title">Your Courses</div>

            <asp:Panel ID="pnlCourseList" runat="server">
                <asp:PlaceHolder ID="phCourses" runat="server" />
            </asp:Panel>

            <asp:Panel ID="pnlNoCourses" runat="server" Visible="false">
                <div style="text-align:center;padding:24px;color:#94a3b8;font-size:13px;">
                    <i class="fa fa-info-circle" style="font-size:20px;margin-bottom:8px;display:block;"></i>
                    No courses pending evaluation for this semester.
                </div>
            </asp:Panel>
        </div>

        <div class="card">
            <asp:Panel ID="pnlFormEmpty" runat="server" style="display:block;">
                <div class="form-empty">
                    <div class="form-empty-icon"><i class="fa fa-star"></i></div>
                    <div class="form-empty-title">Select a course to begin</div>
                    <div class="form-empty-sub">Choose a course from the list to start your evaluation</div>
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlSuccess" runat="server" style="display:none;">
                <div class="success-state">
                    <div class="success-icon"><i class="fa fa-check"></i></div>
                    <div class="success-title">Thank You!</div>
                    <div class="success-sub">Your evaluation has been submitted successfully.</div>
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlForm" runat="server" style="display:none;">
                <div class="card-title">
                    Evaluate <asp:Label ID="lblSelectedCourse" runat="server" />
                </div>
                <div style="font-size:13px;color:#64748b;margin-top:-12px;margin-bottom:20px;">
                    <asp:Label ID="lblSelectedCourseName" runat="server" />
                </div>

                <div class="star-group">
                    <div class="form-label star-label-text">Overall Rating <span style="color:#ef4444;">*</span></div>
                    <div class="star-row" id="starsOverall">
                        <button type="button" class="star-btn" data-group="overall" data-val="1">&#9733;</button>
                        <button type="button" class="star-btn" data-group="overall" data-val="2">&#9733;</button>
                        <button type="button" class="star-btn" data-group="overall" data-val="3">&#9733;</button>
                        <button type="button" class="star-btn" data-group="overall" data-val="4">&#9733;</button>
                        <button type="button" class="star-btn" data-group="overall" data-val="5">&#9733;</button>
                        <span class="star-val" id="valOverall"></span>
                    </div>
                </div>

                <div class="star-group">
                    <div class="form-label star-label-text">Teaching Quality</div>
                    <div class="star-row" id="starsLecturer">
                        <button type="button" class="star-btn" data-group="lecturer" data-val="1">&#9733;</button>
                        <button type="button" class="star-btn" data-group="lecturer" data-val="2">&#9733;</button>
                        <button type="button" class="star-btn" data-group="lecturer" data-val="3">&#9733;</button>
                        <button type="button" class="star-btn" data-group="lecturer" data-val="4">&#9733;</button>
                        <button type="button" class="star-btn" data-group="lecturer" data-val="5">&#9733;</button>
                        <span class="star-val" id="valLecturer"></span>
                    </div>
                </div>

                <div class="star-group">
                    <div class="form-label star-label-text">Course Materials</div>
                    <div class="star-row" id="starsCourse">
                        <button type="button" class="star-btn" data-group="course" data-val="1">&#9733;</button>
                        <button type="button" class="star-btn" data-group="course" data-val="2">&#9733;</button>
                        <button type="button" class="star-btn" data-group="course" data-val="3">&#9733;</button>
                        <button type="button" class="star-btn" data-group="course" data-val="4">&#9733;</button>
                        <button type="button" class="star-btn" data-group="course" data-val="5">&#9733;</button>
                        <span class="star-val" id="valCourse"></span>
                    </div>
                </div>

                <asp:DropDownList ID="ddlCourse" runat="server" CssClass="hidden-ddl" />
                <asp:DropDownList ID="ddlRating" runat="server" CssClass="hidden-ddl">
                    <asp:ListItem Value="">-- Select --</asp:ListItem>
                    <asp:ListItem>1</asp:ListItem><asp:ListItem>2</asp:ListItem>
                    <asp:ListItem>3</asp:ListItem><asp:ListItem>4</asp:ListItem>
                    <asp:ListItem>5</asp:ListItem>
                </asp:DropDownList>
                <asp:DropDownList ID="ddlLecturerRating" runat="server" CssClass="hidden-ddl">
                    <asp:ListItem Value=""></asp:ListItem>
                    <asp:ListItem>1</asp:ListItem><asp:ListItem>2</asp:ListItem>
                    <asp:ListItem>3</asp:ListItem><asp:ListItem>4</asp:ListItem>
                    <asp:ListItem>5</asp:ListItem>
                </asp:DropDownList>
                <asp:DropDownList ID="ddlCourseRating"   runat="server" CssClass="hidden-ddl">
                    <asp:ListItem Value=""></asp:ListItem>
                    <asp:ListItem>1</asp:ListItem><asp:ListItem>2</asp:ListItem>
                    <asp:ListItem>3</asp:ListItem><asp:ListItem>4</asp:ListItem>
                    <asp:ListItem>5</asp:ListItem>
                </asp:DropDownList>

                <div class="form-group">
                    <label class="form-label">Additional Comments (Optional)</label>
                    <asp:TextBox ID="txtComment" runat="server"
                        TextMode="MultiLine" Rows="4"
                        CssClass="form-textarea"
                        placeholder="Share your thoughts about the course and instructor..." />
                </div>

                <div class="anon-row">
                    <asp:CheckBox ID="chkAnonymous" runat="server" />
                    <label for="<%= chkAnonymous.ClientID %>">Submit anonymously</label>
                </div>

                <asp:Button ID="btnSubmit" runat="server"
                    Text="Submit Evaluation"
                    CssClass="btn-submit"
                    OnClick="btnSubmit_Click"
                    OnClientClick="return validateStars();" />
            </asp:Panel>
        </div>
    </div>

    <div class="card">
        <div class="card-title">My Submitted Evaluations</div>

        <div style="overflow-x:auto;">
            <asp:GridView ID="gvEvaluation" runat="server"
                AutoGenerateColumns="false"
                CssClass="gv-eval"
                GridLines="None"
                EmptyDataText="">
                <EmptyDataRowStyle CssClass="empty-row" />
                <Columns>
                    <asp:TemplateField HeaderText="Course">
                        <ItemTemplate>
                            <span class="badge badge-course"><%# Eval("CourseCode") %></span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Overall">
                        <ItemTemplate>
                            <%# RenderStars(Eval("Rating")) %>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Teaching">
                        <ItemTemplate>
                            <%# RenderStars(Eval("LecturerRating")) %>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Materials">
                        <ItemTemplate>
                            <%# RenderStars(Eval("CourseRating")) %>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Comment">
                        <ItemTemplate>
                            <div class="comment-cell" title="<%# Eval("Comment") %>">
                                <%# string.IsNullOrWhiteSpace(Eval("Comment")?.ToString()) ? "—" : Eval("Comment").ToString() %>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Submitted">
                        <ItemTemplate>
                            <%# FormatDate(Eval("SubmittedAt")) %>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>

        <asp:Panel ID="pnlEvalEmpty" runat="server" Visible="false">
            <div style="text-align:center;padding:48px;color:#94a3b8;">
                <i class="fa fa-star-o" style="font-size:32px;display:block;margin-bottom:12px;"></i>
                <div style="font-size:15px;font-weight:600;color:#475569;">No evaluations submitted yet</div>
                <div style="font-size:13px;margin-top:4px;">Select a course above to submit your first evaluation</div>
            </div>
        </asp:Panel>
    </div>

</div>

<script>
    var ratings = { overall: 0, lecturer: 0, course: 0 };

    var ddlMap = {
        overall:  '<%= ddlRating.ClientID %>',
        lecturer: '<%= ddlLecturerRating.ClientID %>',
        course:   '<%= ddlCourseRating.ClientID %>'
    };

    var valMap = { overall: 'valOverall', lecturer: 'valLecturer', course: 'valCourse' };
    var labels = ['', 'Poor', 'Fair', 'Good', 'Very Good', 'Excellent'];

    document.addEventListener('DOMContentLoaded', function () {
        document.querySelectorAll('.star-btn').forEach(function (btn) {
            btn.addEventListener('click', function () {
                var group = this.dataset.group;
                var val   = parseInt(this.dataset.val);
                setRating(group, val);
            });

            btn.addEventListener('mouseenter', function () {
                var group = this.dataset.group;
                var val   = parseInt(this.dataset.val);
                highlightStars(group, val);
            });

            btn.addEventListener('mouseleave', function () {
                var group = this.dataset.group;
                highlightStars(group, ratings[group]);
            });
        });
    });

    function setRating(group, val) {
        ratings[group] = val;
        highlightStars(group, val);

        var ddl = document.getElementById(ddlMap[group]);
        if (ddl) ddl.value = val;

        var lbl = document.getElementById(valMap[group]);
        if (lbl) lbl.innerText = labels[val] || '';
    }

    function highlightStars(group, val) {
        document.querySelectorAll('.star-btn[data-group="' + group + '"]').forEach(function (s) {
            s.classList.toggle('active', parseInt(s.dataset.val) <= val);
        });
    }

    function validateStars() {
        if (ratings.overall === 0) {
            alert('Please select an overall rating before submitting.');
            return false;
        }
        return confirm('Submit your evaluation?');
    }

    window.onload = function () {
        var lbl = document.getElementById('<%= lblMsg.ClientID %>');
        if (!lbl || !lbl.innerText.trim()) return;
        var isError = lbl.style.color === 'red' || lbl.style.color === 'rgb(255, 0, 0)';
        lbl.className = isError ? 'msg-error' : 'msg-success';
        lbl.innerHTML = '<i class="fa ' + (isError ? 'fa-exclamation-circle' : 'fa-check-circle') + '"></i> ' + lbl.innerText;
    };

    function selectCourse(offeringID, courseCode, courseName) {
        var ddl = document.getElementById('<%= ddlCourse.ClientID %>');
        if (ddl) ddl.value = offeringID;

        document.querySelectorAll('.course-btn').forEach(function (b) {
            b.classList.remove('selected');
        });
        event.currentTarget.classList.add('selected');

        document.querySelector('[id$="lblSelectedCourse"]').innerText = courseCode;
        document.querySelector('[id$="lblSelectedCourseName"]').innerText = courseName;

        document.getElementById('<%= pnlForm.ClientID %>').style.display = 'block';
        document.getElementById('<%= pnlFormEmpty.ClientID %>').style.display = 'none';
        document.getElementById('<%= pnlSuccess.ClientID %>').style.display = 'none';
    }
</script>
</asp:Content>
