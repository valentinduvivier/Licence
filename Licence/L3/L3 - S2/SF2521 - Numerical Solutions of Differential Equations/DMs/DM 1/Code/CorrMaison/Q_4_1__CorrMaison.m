
% Elementary information : 
%     - each major question using Matlab has its own section ;
%     - you should still run them in the order of appearance
%     to make shure every variable are computed at least once ;
% 

%% Q_4.1

% Initialisation data

    clear all

    % Space variables
        Lx = 1; Ly = 1;         % Dimensions of the area over which we descretize
        M = 30; N = 10;         % Number of point considered for the discretization

        Dx = Lx/M; Dy = Ly/N;   % Space step

    % Time variables
        T = 10;         % The code will be running for 10s
        N_t = 100;      % Time scale - Nb of iter°

        Dt = T/N_t;     % Time step

    % Diverse variables
        w = 1/4;
        
    % We create point to define the mesh for the dicretization
    x = linspace(0,Lx,M);
    y = linspace(0,Ly,N);

    Q = zeros(M,N);     % As i = 1 --> M and j = 1 --> N


%  % ---------------------------------------------------------------------------------------------------------------------------- %        


% Boundary condition : Nabla Q * n = 0 :

    % The boundar condition (no flux oat the boundaries) is sumed up in the
    % matrix A as the no flux cd° has an impact on the second derivative
    % difference operator's matrix
    
%  % ---------------------------------------------------------------------------------------------------------------------------- %         
    

% Drawing Sources

    % Origin point for the sources (xs,ys) :
        xs = 1/2; ys = 1/2;

    % Source S1

        [X1,Y1] = meshgrid(x,y);
        S1 = exp(-((X1 - xs).^2 + (Y1 - ys).^2)/(w^2));

        % To uncomment if you want to display the source S1
        figure(11)
        subplot(1,2,1);
        surf(X1,Y1,S1);
        shading flat;
        title(['S1 for a mesh of ',num2str(M),'-by-',num2str(N),' points, at t_{0}']);
        xlabel('x'); ylabel('y');
        hold on

    % Source S2
         
        [X2,Y2] = meshgrid(x,y);

        r = sqrt(((X2 - xs).^2 + (Y2 - ys).^2));
        eps = sqrt(max(Dx,Dy));

        S2 = zeros(N,M);

        for i = 1:M
            for j = 1:N
                if r(j,i) < eps
                    S2(j,i) = 2*(pi/(eps^2*((pi^2) - 4))) * (1 + cos((pi/eps)*r(j,i)));
                end
            end
        end

        % To uncomment if you want to display the source S2
        % figure 1 as well
        subplot(1,2,2);
        surf(X2,Y2,S2);
        shading flat;
        title(['S2 for a mesh of ',num2str(M),'-by-',num2str(N),' points, at t_{0}']);
        xlabel('x'); ylabel('y');
        hold off

%  % ---------------------------------------------------------------------------------------------------------------------------- %        


% Creation matrix Tx/Ty

%     % Matrix A (leads to Tx or Ty)
%     % We consider two different A :
%     %   - one of the size of M
%     %   - one of the size of N
%     
%     % Thus, we will be able to consider every cases :
%     %   - the ones where there is a different number of column and line
%     %   - the particular case where we will have as much lines as columns
%     
%     

%  % ---------------------------------------------------------------------------------------------------------------------------- %        
%      
      
    % Ax
        Ax = zeros(M);

        % Diagonal
            % (See BC)
                Ax(1,1) = -1;
                Ax(M,M) = -1;

            for k = 2:M-1
                Ax(k,k) = -2;
            end

        % Diagonal superior & inferior
            for k = 1:M-1
                Ax(k,k+1) = 1;

                Ax(k+1,k) = 1;
            end
        
    % Ay
        Ay = zeros(N);

        % Diagonal
            % (See BC)
                Ay(1,1) = -1;
                Ay(N,N) = -1;

            for k = 2:N-1
                Ay(k,k) = -2;
            end

        % Diagonal superior & inferior
            for k = 1:N-1
                Ay(k,k+1) = 1;

                Ay(k+1,k) = 1;
            end

        
%  % ---------------------------------------------------------------------------------------------------------------------------- %        
        
        
% Heat function
        % We apply the Kronecker product to get matrices of the same size
            
            % We refine the vectors (x+1) & (y+1) using the eye function.
            % We considered (x+1) & (y+1) rather than x & y as we have
            % (x(0),y(0)) = (0,0), which brings an instability at the same
            % point.
            Px = eye(size(x,2)).*(x+1); 
            Py = eye(size(y,2)).*(y+1);
            
            Tx = sparse(kron(Ax,Py))/Dx^2; 
            Ty = sparse(kron(Px,Ay))/Dy^2;

        % We introduce a matrix identity of the size of the one jus above
            I = eye(M*N);
        
        % Constant matrices
            A = sparse(I - Dt*(Tx+Ty));
            [L,U] = lu(A);
        
        % Reorganisation of matrix Q as a column vector
            QQ = sparse(reshape(Q,[],1));
        
        % Matrix gathering QQ over time. This matrix will allow us to deal
        % with the heat function over time
            FF = sparse([QQ]);

% S1 - Uncomment all if you're willing to test S1   

        % Source vector
        SS = sparse(reshape(S1,[],1));

        for t = 1:N_t     % We loop for as many itera° as we have 
            Y = L^-1*(QQ + Dt*SS);
            QQ = U^-1*Y;  % Resolution of heat equation in 2D with source
            
            %  We ensure that the temperature inside the mesh dosn't go
            %  above the source heat
            for k = 1:size(QQ,1)
               if QQ(k,1) > max(SS)
                  QQ(k,1) = max(SS);
               end
            end
            
            FF = [FF QQ];       % We concatenate the value of QQ over time in FF
        end
        
        FF = FF(:,2:end);
        
% S2 - Uncomment all if you're willing to test S2 

%         SS = reshape(S2,[],1);
% 
%         for t = 1:N_t
%             
%             while Dt*t < 0.25
%                 Y = L^-1*(QQ + Dt*SS);
%                 QQ = U^-1*Y;                % Resolution of heat equation in 2D with source
%                 
%                 % We ensure that the temperature inside the mesh dosn't go
%                 % above the source heat
%                 for k = 1:size(QQ,1)
%                    if QQ(k,1) > max(SS)
%                       QQ(k,1) = max(SS);
%                    end
%                 end
%                 
%                 FF = [FF QQ];
%                 
%                 t = t + 1;
%             end
%             
%             Y = L^-1*QQ;
%             QQ = U^-1*Y;            
%              
%             % We ensure that the temperature inside the mesh dosn't go
%             % above the source heat
%             for k = 1:size(QQ,1)
%                 if QQ(k,1) > max(SS)
%                   QQ(k,1) = max(SS);
%                 end
%             end
%             
%             FF = [FF QQ];       % We concatenate the value of QQ over time in FF
%         end
%         
%         FF = FF(:,2:end);

%  % ---------------------------------------------------------------------------------------------------------------------------- %        
%%

% Display of the results
        
        t_1 = round(N_t/100); t_2 = round(N_t/50); t_3 = round(N_t/30); t_4 = round(N_t/20);
        
        figure(12)
        HM1 = imagesc(reshape(FF(:,t_1),M,N)); 
        title(['Heat repartition, t = ',num2str(Dt*t_1),'s for S1']);
        xlabel('x'); ylabel('y');
        
        figure(13)
        HM1 = imagesc(reshape(FF(:,t_2),M,N)); 
        title(['Heat repartition, t = ',num2str(Dt*t_2),'s for S1']);
        xlabel('x'); ylabel('y');
        
        figure(14)
        HM1 = imagesc(reshape(FF(:,t_3),M,N)); 
        title(['Heat repartition, t = ',num2str(Dt*t_3),'s for S1']);
        xlabel('x'); ylabel('y');
        
        figure(15)
        HM1 = imagesc(reshape(FF(:,t_4),M,N)); 
        title(['Heat repartition, t = ',num2str(Dt*t_4),'s for S1']);
        xlabel('x'); ylabel('y');


        % Drawing

        figure(16)
            for k = 1:N_t
                HM1 = surf(reshape(FF(:,k),M,N));                
%                 axis([x_lim_inf_s x_lim_sup_s y_lim_inf_s y_lim_sup_s]);
                xlabel('x position'); ylabel('y position'); zlabel('Heat (°C)'); title(['Heat over the mesh in the case of source S2 at t = ',num2str(round(Dt*k,2)),' s']);
                drawnow
            end
            
            