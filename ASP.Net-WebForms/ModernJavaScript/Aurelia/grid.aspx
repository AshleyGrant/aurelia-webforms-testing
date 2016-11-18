<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="grid.aspx.cs" Inherits="ModernJavaScript.Knockout.grid" MasterPageFile="~/Site.Master" %>

<asp:Content runat="server" ContentPlaceHolderID="MainContent">

    <div data-ng-app="myContent">

        <h2>Aurelia Grid Sample</h2>

        <p>
            Our markup should be pretty standard to databind our grid. This simple grid is configured to load 3 customer
      records that are hardcoded into our code-behind and accessible through a GetCustomers method that was perfect for server-side model binding, but when a static keyword and a WebMethodAttribute are added, it now delivers data to the client.
   
        </p>

        <p>As a desired outcome of the translation, any data formatting that was defined in a bound column of a template column should be translated to appropriate JavaScript formatting using the Knockout template langauge.  At its simplest, a BoundColumn with no formatting should be translated like this:</p>

        <h4>Server-Side</h4>
        <code>&lt;asp:BoundField DataField="FirstName" HeaderText="First Name" /&gt; 
    </code>

        <p>
            As a principle, any server-side configuration that a developer expected on the control should be applied identically with the client-side framework.
   
        </p>

        <h4>Rendered HTML</h4>
        <code>&lt;th&gt;First Name&lt;/th&gt;<br />
            ...</br>
      &lt;td&gt;&lt;!--ko text: FirstName --&gt;&lt;!--/ko--&gt;&lt;/td&gt;
    </code>
        <br />
        <br />

        <p>With Knockout, we need to add transportation for the data.  In this scenario, we have configured a WebAPI endpoint that this sample will use to databind against.  We could use a PageMethod with syntax similar to that demonstrated in the <a href="/Angular1/grid.aspx">Angular 1 Grid sample</a></p>

        <code>&lt;asp:GridView runat="server" ID="GridView1" ClientIDMode="Static"<br />
            AutoGenerateColumns="false"<br />
            <b>ClientDataBinding="<%: IsClientSideDataBindingEnabled.ToString().ToLowerInvariant() %>"</b> &gt;<br />
        </code>

        <br />

        <asp:LinkButton runat="server" ID="ToggleLink" OnClick="ToggleLink_Click">
      Get Data using <%: IsClientSideDataBindingEnabled ? "Server-Side" : "Client-Side" %> data binding
    </asp:LinkButton>


        <%-- 
    
    PROPOSED CODE CHANGE
  
    Additional attribute supported:  @ClientDataBinding: bool  
      Activates Modern JavaScript Rendering and client-side databinding

    --%>
        <h3>Sample</h3>

        <asp:GridView runat="server" ID="myGrid" ClientIDMode="Static" AutoGenerateColumns="false"
            ClientDataBinding="true">
            <%-- 
      The proposed additional configuration property is configured on this grid and some code is present in the 
      code-behind to appropriately trigger the EmptyDataTemplate rendering, which contains the proposed
      output HTML in its simplest format.
      --%>
            <EmptyDataTemplate>
                <table id="myGrid">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>First Name</th>
                            <th>Last Name</th>
                            <th>First Order Date</th>
                        </tr>
                    </thead>
                    <tbody repeat.for="customer of Customers" data-bind="foreach: Customers">
                        <tr>
                            <td>
                                <!--ko text: ID -->
                                <!--/ko-->
                                ${customer.ID}</td>
                            <td>
                                <!--ko text: FirstName -->
                                <!--/ko-->
                                ${customer.FirstName}</td>
                            <td>
                                <!--ko text: LastName -->
                                <!--/ko-->
                                ${customer.LastName}</td>
                            <td>
                                <!--ko text: FormatDate(FirstOrderDate) -->
                                <!--/ko-->
                                ${FormatDate(customer.FirstOrderDate)}</td>
                        </tr>
                    </tbody>
                </table>
            </EmptyDataTemplate>
            <Columns>
                <asp:BoundField DataField="ID" HeaderText="ID" />
                <asp:BoundField DataField="FirstName" HeaderText="First Name" />
                <asp:BoundField DataField="LastName" HeaderText="Last Name" />
                <asp:BoundField DataField="FirstOrderDate" HeaderText="First Order Date" DataFormatString="{0:d}" />
            </Columns>
        </asp:GridView>

    </div>

</asp:Content>

<asp:Content runat="server" ContentPlaceHolderID="endOfPage">

    <% if (IsClientSideDataBindingEnabled)
        { %>

    <!-- 
    This script is only added when ClientSideDataBinding is set to TRUE

    We fully expect this code to be generated by the adapter or an HttpModule and injected into the page directly or a reference added to an HttpModule that will emit this code.
    -->

    <script src="au-scripts/system.js"></script>
    <script src="au-scripts/config-esnext.js"></script>
    <script src="au-scripts/aurelia-core.js"></script>
    <script type="text/javascript">

        var myViewModel = {

            /* This type of utility function should be part of our standard MSAjax framework for handling data presented
               by a PageMethod or WebAPI end-point
            */


            FormatDate: function (dt) {
                return (dt.getMonth() + 1).toString() + "/" + (dt.getDate()).toString() + "/" + dt.getFullYear().toString();
            }
        };
        // Knockout method
        (function () {

            PageMethods.GetCustomers(onSuccess);
            // jQuery
            //$.get("/api/Customer")
              function onSuccess(data) {

                  // Convert back to a date
                  data.forEach(customer => {
                      customer.FirstOrderDate = new Date(Date.parse(customer.FirstOrderDate));
                  });

                  console.log(data); // Added for debugging and demonstration purposes

                  myViewModel.Customers = data;

                  System.import('aurelia-bootstrapper')
      .then(bootstrapper => {
          bootstrapper.bootstrap(function (aurelia) {
              aurelia.use
              .basicConfiguration()
              .developmentLogging();

              aurelia.start().then(app => {
                  System.import('aurelia-framework').then(framework => {
                      const TemplatingEngine = framework.TemplatingEngine;

                      //window.aureliaViewModelDefinitions.Button_3 = class {
                      //    constructor() {
                      //        this.buttonText = 'Click me 3';
                      //    }

                      //    getViewStrategy() {
                      //        this.viewStrategy = new InlineViewStrategy('<template>I\'m from a string template. <button click.delegate="showMessage()">${buttonText}</button></template>');
                      //        return this.viewStrategy;
                      //    }

                      //    showMessage() {
                      //        alert("I was clicked 3");
                      //    }
                      //};

                      let templatingEngine = app.container.get(TemplatingEngine);
                      const element = document.getElementById("myGrid");

                      templatingEngine.enhance({
                          container: app.container,
                          element: element,
                          resources: app.resources,
                          bindingContext: myViewModel
                      });

                      //let elements = document.querySelectorAll("*[aspx-enhance]");

                      //for(const element of elements) {
                      //    const vmClassName = element.getAttribute('aspx-enhance');

                      //    const vm = new window.aureliaViewModelDefinitions[vmClassName];

                      //    const viewStrategy = vm.getViewStrategy ? vm.getViewStrategy() : null;

                      //    templatingEngine.enhance({
                      //        container: app.container,
                      //        element: element,
                      //        resources: app.resources,
                      //        bindingContext: vm
                      //    });
                      //}
                  });
              });
          });
      });

              };

        })();

  </script>
    <% } // End IsClientSideDataBindingEnabled check %>
</asp:Content>
